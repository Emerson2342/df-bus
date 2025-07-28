import 'dart:async';

import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/controller/storage_controller.dart';
import 'package:df_bus/helpers/map_style.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/line_details_notifier.dart';
import 'package:df_bus/value_notifiers/show_maps_notifier.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class MapsWidget extends StatefulWidget {
  const MapsWidget({super.key});

  @override
  State<MapsWidget> createState() => MapsWidgetState();
}

class MapsWidgetState extends State<MapsWidget> {
  late Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  final searchLineController = getIt<SearchLineController>();
  final busLineNotifier = getIt<BusLineNotifier>();

  final storageController = getIt<StorageController>();
  final themeNotifier = getIt<ThemeNotifier>();
  final showLineDetailsNotifier = getIt<ShowLineDetailsMapsNotifier>();

  List<FeatureRoute> _busRoute = [];
  List<List<LatLng>> pointsOnMap = [];
  Set<Polyline> _polylines = {};
  Set<Marker> markes = {};
  Timer? _timer;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor piraIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor urbiIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor bsBusIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor marechalIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor piorneiraIcon = BitmapDescriptor.defaultMarker;
  String? _mapStyle;
  bool loadingBusRoute = true;
  bool loadingBusLocation = true;
  Color? textColor;

  final CameraPosition _initialCameraPosition =
      CameraPosition(target: LatLng(-15.793112, -47.884543), zoom: 10);

  @override
  void initState() {
    _clearAll();
    debugPrint(">>>>>>>>Entrou na tela MAPS DETAILS LINE");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      textColor = Theme.of(context).colorScheme.secondary;
    });
    showLineDetailsNotifier.addListener(_handleVisibilityChange);
    _handleMapStyleMode();
    themeNotifier.addListener(_handleMapStyleMode);

    _loadCustomIcon();

    super.initState();
  }

  @override
  void dispose() {
    _clearAll();
    super.dispose();
  }

  void _handleMapStyleMode() async {
    final style = await getMapstyle();
    setState(() {
      _mapStyle = style;
    });
  }

  void _handleVisibilityChange() {
    if (showLineDetailsNotifier.value) {
      _init();

      _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        await _getBusLocation();
      });
    } else {
      _clearAll();
    }
  }

  void _clearAll() {
    if (!mounted) return;
    setState(() {
      _busRoute.clear();
      pointsOnMap.clear();
      _polylines.clear();
      markes.clear();
      _timer?.cancel();
      loadingBusRoute = true;
      loadingBusLocation = true;
    });
  }

  Future<void> _init() async {
    await _getBusroute();

    setState(() {
      loadingBusLocation = true;
    });
    await _getBusLocation();
    setState(() {
      loadingBusLocation = false;
    });
    _initMarkers();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_polylines.isNotEmpty) {
        await setInitialCamera(mapController, _polylines);
      }
    });
  }

  void _loadCustomIcon() {
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/bus_stop.png")
        .then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/bs_bus.png")
        .then((icon) {
      setState(() {
        bsBusIcon = icon;
      });
    });
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/marechal.png")
        .then((icon) {
      setState(() {
        marechalIcon = icon;
      });
    });
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/pioneira.png")
        .then((icon) {
      setState(() {
        piorneiraIcon = icon;
      });
    });
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/piracicabana.png")
        .then((icon) {
      setState(() {
        piraIcon = icon;
      });
    });
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/urbi.png")
        .then((icon) {
      setState(() {
        urbiIcon = icon;
      });
    });
  }

  void _initMarkers() {
    final newPolylines = <Polyline>{};

    final isCircular = pointsOnMap.length == 1;
    final isIdaVolta = pointsOnMap.length == 2;
    debugPrint(
        "********************Tamanho da lista - Init Markers  ${busLineNotifier.value} ${pointsOnMap.length}");

    for (int i = 0; i < pointsOnMap.length; i++) {
      Color? color;

      if (isCircular) {
        color = Colors.amber;
      } else if (isIdaVolta) {
        color = i == 0 ? Colors.amber : const Color.fromARGB(255, 45, 156, 65);
      } else {
        color = Colors.blueGrey;
      }

      newPolylines.add(
        Polyline(
          polylineId: PolylineId('polyline-$i'),
          points: pointsOnMap[i],
          color: color,
          width: 2,
        ),
      );
    }
    if (!mounted) return;
    _polylines = newPolylines;
  }

  Future<void> _getBusLocation() async {
    final newMarkers = <Marker>{};
    final geoLocation = await searchLineController.getBusLocation(
        busLineNotifier.value, context);
    debugPrint(
        "***************Chamou localização dos ônibus - ${busLineNotifier.value}");
    if (geoLocation == null) {
      //showLineDetailsNotifier.value = false;
      return;
    }

    BitmapDescriptor busIcon;
    for (int index = 0; index < geoLocation.features.length; index++) {
      final item = geoLocation.features[index];
      final lon = item.geometry.coordinates[0];
      final lat = item.geometry.coordinates[1];
      final busNumber = NumberFormat.decimalPattern('pt_BR')
          .format(double.tryParse(item.properties.numero));
      final lastUpdate =
          DateTime.fromMillisecondsSinceEpoch(item.properties.horario);
      final diff = DateTime.now().difference(lastUpdate);

      final seconds = diff.inSeconds % 60;
      final textUpdate = diff.inMinutes == 0
          ? 'Última atualização: $seconds segundos atrás'
          : 'Última atualização: ${diff.inMinutes} min e $seconds segundos atrás';

      if (item.properties.idOperadora == 3441) {
        busIcon = urbiIcon;
      } else if (item.properties.idOperadora == 3444) {
        busIcon = marechalIcon;
      } else if (item.properties.idOperadora == 3449) {
        busIcon = piorneiraIcon;
      } else if (item.properties.idOperadora == 3450) {
        busIcon = bsBusIcon;
      } else if (item.properties.idOperadora == 3437) {
        busIcon = piraIcon;
      } else {
        busIcon = BitmapDescriptor.defaultMarker;
      }
      newMarkers.add(
        Marker(
          markerId: MarkerId("marker -$index"),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(
              title: "Linha: ${item.properties.linha} - Ônibus: $busNumber",
              snippet: textUpdate),
          icon: busIcon,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      markes = newMarkers;
    });
  }

  Future<void> setInitialCamera(
    Completer<GoogleMapController> mapController,
    Set<Polyline> polylines,
  ) async {
    if (polylines.isEmpty) return;

    List<LatLng> allPoints = [];
    for (var polyline in polylines) {
      allPoints.addAll(polyline.points);
    }

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (var point in allPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final controller = await mapController.future;

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    setState(() {});
  }

  Future<void> _getBusroute() async {
    _busRoute.clear();
    pointsOnMap.clear();
    setState(() {
      loadingBusRoute = true;
    });
    final isRouteSaved =
        await storageController.isAlreadySaved(busLineNotifier.value);

    if (isRouteSaved) {
      _busRoute = await storageController.getBusRoute(busLineNotifier.value);
    } else {
      _busRoute = await searchLineController.getBusRoute(busLineNotifier.value);
      for (final route in _busRoute) {
        await storageController.addBusRoute(route);
      }
    }

    for (final feature in _busRoute) {
      final coords = feature.geometry.coordinates;

      final List<LatLng> singleRoute = coords.map<LatLng>((coord) {
        final lat = coord[1];
        final lng = coord[0];
        return LatLng(lat, lng);
      }).toList();
      pointsOnMap.add(singleRoute);
    }
    setState(() {
      loadingBusRoute = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(children: [
              Positioned.fill(
                child: GoogleMap(
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  markers: markes,
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    mapController.complete(controller);
                    debugPrint(
                        '++++++++++++++++++[GoogleMap] Mapa foi criado!');
                  },
                  style: _mapStyle,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (loadingBusLocation)
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          SizedBox(width: 7),
                          Text(
                            "Carregando a localização dos ônibus...",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    if (loadingBusRoute)
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: textColor),
                          ),
                          SizedBox(width: 7),
                          Text(
                            "Carregando a rota do ônibus...",
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ]),
          ),
          AdsBannerWidget(),
        ],
      ),
    );
  }
}

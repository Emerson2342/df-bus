import 'dart:async';

import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class MapsWidget extends StatefulWidget {
  const MapsWidget({super.key, required this.busRoute, required this.busLine});

  final List<int> busRoute;
  final String busLine;

  @override
  State<MapsWidget> createState() => MapsWidgetState();
}

class MapsWidgetState extends State<MapsWidget> {
  late Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  final searchLineController = getIt<SearchLineController>();
  final themeNotifier = getIt<ThemeNotifier>();

  final List<FeatureBusRoute> _busRoute = [];
  List<List<LatLng>> pointsOnMap = [];
  Set<Polyline> _polylines = {};
  Set<Marker> markes = {};
  Timer? _timer;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  String? _mapStyle;
  bool loadingBusRoute = true;
  bool loadingBusLocation = true;
  static bool _isRequestingPermission = false;

  //Position? _currentPosition;
  final CameraPosition _initialCameraPosition =
      CameraPosition(target: LatLng(-15.793112, -47.884543), zoom: 15);

  @override
  void initState() {
    _clearAll();
    // _setMapStyle();

    rootBundle
        .loadString(themeNotifier.isDarkMode
            ? 'assets/maps/map_style_dark.json'
            : 'assets/maps/map_style_light.json')
        .then((string) {
      setState(() {
        _mapStyle = string;
      });
    });
    _loadCustomIcon();
    _init();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _getBusLocation();
    });
    super.initState();
  }

  @override
  void dispose() {
    _clearAll();
    super.dispose();
  }

  void _clearAll() {
    _busRoute.clear();
    pointsOnMap.clear();
    _polylines.clear();
    markes.clear();
    _timer?.cancel();
  }

  void _loadCustomIcon() {
    BitmapDescriptor.asset(ImageConfiguration(), "assets/images/bus.png")
        .then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
  }

  Future<void> _init() async {
    await _requestLocationPermission();
    await _getBusroute();
    await _getBusLocation();
    _initMarkers();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_polylines.isNotEmpty) {
        await setInitialCamera(mapController, _polylines);
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    if (_isRequestingPermission) return;
    _isRequestingPermission = true;

    try {
      var status = await Permission.location.status;

      if (status.isDenied ||
          status.isRestricted ||
          status.isPermanentlyDenied) {
        status = await Permission.location.request();
        _isRequestingPermission = false;
      }

      if (mounted && status.isGranted) {
        setState(() {});
      } else {
        // openAppSettings();
      }
    } finally {
      _isRequestingPermission = false;
    }
  }

  void _initMarkers() {
    final newPolylines = <Polyline>{};

    final isCircular = pointsOnMap.length == 1;
    final isIdaVolta = pointsOnMap.length == 2;
    debugPrint(
        "********************Tamanho da lista - Init Markers  ${widget.busLine} ${pointsOnMap.length}");

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
    // setState(() {
    _polylines = newPolylines;
    // });
  }

  Future<void> _getBusLocation() async {
    final newMarkers = <Marker>{};
    final geoLocation =
        await searchLineController.getBusLocation(widget.busLine);
    debugPrint("***************Chamou localização dos ônibus");
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
      newMarkers.add(
        Marker(
          markerId: MarkerId("marker -$index"),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(
              title: "Linha: ${item.properties.linha} - Ônibus: $busNumber",
              snippet: textUpdate),
          icon: customIcon,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      markes = newMarkers;
      loadingBusLocation = false;
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
    if (!mounted) return;

    final busRoute = await searchLineController.getBusRoute(widget.busLine);

    for (final feature in busRoute.features) {
      final coords = feature.geometry.coordinates;

      final List<LatLng> singleRoute = coords.map<LatLng>((coord) {
        final lat = coord[1];
        final lng = coord[0];
        return LatLng(lat, lng);
      }).toList();
      pointsOnMap.add(singleRoute);
    }
    if (!mounted) return;
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
                  },
                  style: _mapStyle,
                ),
              ),
              if (loadingBusRoute)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 0,
                  child: Text(
                    "Carregando a rota do ônibus...",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              if (loadingBusLocation)
                Positioned(
                  top: 30,
                  left: 10,
                  right: 0,
                  child: Text(
                    "Carregando a localização dos ônibus...",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold),
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

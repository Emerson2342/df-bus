import 'dart:async';
import 'dart:convert';

import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/helpers/position_widget.dart';
import 'package:df_bus/models/bus_location.dart';
import 'package:df_bus/models/bus_stop.dart';
import 'package:df_bus/pages/bus_stop_page/widgets/bus_stop_lines.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusStopPage extends StatefulWidget {
  const BusStopPage({super.key});

  @override
  State<BusStopPage> createState() => _BusStopPageState();
}

class _BusStopPageState extends State<BusStopPage>
    with AutomaticKeepAliveClientMixin {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final searchLineController = getIt<SearchLineController>();

  final themeNotifier = getIt<ThemeNotifier>();
  String? _mapStyle;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor piraIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor urbiIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor bsBusIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor marechalIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor piorneiraIcon = BitmapDescriptor.defaultMarker;
  late ClusterManager clusterManager;
  Position? position;
  late CameraPosition _myCameraPosition;
  bool loadingAllBusLocation = true;

  Set<Marker> _markers = {};

  List<BusStop> busStops = [];
  List<AllBusLocation> allBusLocation = [];

  void _loadCustomIcon() {
    BitmapDescriptor.asset(ImageConfiguration(), "assets/images/bus.png")
        .then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/bs_bus.jpeg")
        .then((icon) {
      setState(() {
        bsBusIcon = icon;
      });
    });
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/marechal.jpeg")
        .then((icon) {
      setState(() {
        marechalIcon = icon;
      });
    });
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/pioneira.jpeg")
        .then((icon) {
      setState(() {
        piorneiraIcon = icon;
      });
    });
    BitmapDescriptor.asset(
            ImageConfiguration(), "assets/icon/piracicabana.jpeg")
        .then((icon) {
      setState(() {
        piraIcon = icon;
      });
    });
    BitmapDescriptor.asset(ImageConfiguration(), "assets/icon/urbi.jpeg")
        .then((icon) {
      setState(() {
        urbiIcon = icon;
      });
    });
  }

  Future<void> _loadBusStops() async {
    final String jsonString =
        await rootBundle.loadString('assets/bus_stop/bus_stop.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    busStops = jsonData.map((e) => BusStop.fromJson(e)).toList();
    debugPrint(
        "Quantidade de parada de ônibus - ${busStops.length.toString()}");
  }

  Future<void> _loadAllBusLocation() async {
    final allLocation = await searchLineController.getAllBusLocation();
    setState(() {
      loadingAllBusLocation = false;
      allBusLocation = allLocation;
    });

    debugPrint(">>>>>>>>>Quantidade de Empresas - ${allBusLocation.length}");
    for (final item in allBusLocation) {
      debugPrint(">>>>>>>>Quantidade de ônibus - ${item.veiculos.length}");
    }
  }

  void _init() async {
    await _loadBusStops();
    await _loadAllBusLocation();
    position = await getCurrentLocation();

    _cameraPosition(position?.latitude, position?.longitude);
    debugPrint(
        ' ------- Latitude: ${position?.latitude}, Longitude: ${position?.longitude}');
  }

  void _cameraPosition(double? lat, double? lng) async {
    final double baseLat = -15.7942;
    final double baseLng = -47.8822;

    setState(() {
      _myCameraPosition = CameraPosition(
        target: LatLng(lat ?? baseLat, lng ?? baseLng),
        zoom: 16,
      );
    });
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_myCameraPosition));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    debugPrint("********************** Mapa Page");
    _loadCustomIcon();
    _myCameraPosition = CameraPosition(
      target: LatLng(-15.7942, -47.8822),
      zoom: 16,
    );
    _init();
    rootBundle.loadString('assets/maps/map_style_dark.json').then((string) {
      if (!themeNotifier.isDarkMode) return;
      setState(() {
        _mapStyle = string;
      });
    });
    super.initState();
  }

  void _onCameraIdle() async {
    final controller = await _controller.future;
    final zoom = await controller.getZoomLevel();
    final bounds = await controller.getVisibleRegion();

    BitmapDescriptor ccustomIcon;

    if (zoom >= 15) {
      final Set<Marker> markers = {};
      for (final item in allBusLocation) {
        if (item.operadora.id == 3441) {
          ccustomIcon = urbiIcon;
        } else if (item.operadora.id == 3444) {
          ccustomIcon = marechalIcon;
        } else if (item.operadora.id == 3449) {
          ccustomIcon = piorneiraIcon;
        } else if (item.operadora.id == 3450) {
          ccustomIcon = bsBusIcon;
        } else if (item.operadora.id == 3437) {
          ccustomIcon = piraIcon;
        } else {
          ccustomIcon = customIcon;
        }

        final allBus = item.veiculos.where((b) {
          return b.localizacao.latitude >= bounds.southwest.latitude &&
              b.localizacao.latitude <= bounds.northeast.latitude &&
              b.localizacao.longitude >= bounds.southwest.longitude &&
              b.localizacao.longitude <= bounds.northeast.longitude;
        });
        markers.addAll(
          allBus.map(
            (b) => Marker(
                markerId: MarkerId(
                    '${b.localizacao.latitude},${b.localizacao.longitude}'),
                position:
                    LatLng(b.localizacao.latitude, b.localizacao.longitude),
                infoWindow: InfoWindow(title: b.linha),
                icon: ccustomIcon),
          ),
        );

        setState(() {
          _markers = markers;
        });
      }
    } else {
      setState(() {
        _markers.clear();
      });
    }

    // if (false) {
    //   final visibles = busStops.where((b) {
    //     return b.lat >= bounds.southwest.latitude &&
    //         b.lat <= bounds.northeast.latitude &&
    //         b.lng >= bounds.southwest.longitude &&
    //         b.lng <= bounds.northeast.longitude;
    //   }).toList();

    //   final newMarkers = visibles
    //       .map(
    //         (b) => Marker(
    //             markerId: MarkerId('${b.lat},${b.lng}'),
    //             position: LatLng(b.lat, b.lng),
    //             infoWindow: InfoWindow(title: b.codDftrans),
    //             icon: customIcon,
    //             onTap: () {
    //               showModalBottomSheet(
    //                   backgroundColor:
    //                       Theme.of(context).scaffoldBackgroundColor,
    //                   context: context,
    //                   builder: (context) {
    //                     return BusStopLinesBottomSheet(
    //                       busStopId: b.codDftrans,
    //                     );
    //                   });
    //             }),
    //       )
    //       .toSet();
    //   setState(() {
    //     _markers = newMarkers;
    //   });
    // } else {
    //   setState(() {
    //     _markers.clear();
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(children: [
              GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                initialCameraPosition: _myCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  // _updateClusters();
                },
                style: _mapStyle,
                markers: _markers,
                onCameraMove: (_) {},
                onCameraIdle: _onCameraIdle,
                compassEnabled: true,
              ),
            ]),
          ),
          AdsBannerWidget()
        ],
      ),
    );
  }
}

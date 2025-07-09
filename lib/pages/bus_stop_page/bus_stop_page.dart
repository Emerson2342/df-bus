import 'dart:async';
import 'dart:convert';

import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/helpers/position_widget.dart';
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
  final themeNotifier = getIt<ThemeNotifier>();
  String? _mapStyle;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  late ClusterManager clusterManager;
  Position? position;
  late CameraPosition _myCameraPosition;

  Set<Marker> _markers = {};

  List<BusStop> busStops = [];

  void _loadCustomIcon() {
    BitmapDescriptor.asset(ImageConfiguration(), "assets/images/bus.png")
        .then((icon) {
      setState(() {
        customIcon = icon;
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

  void _init() async {
    await _loadBusStops();
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

    if (zoom >= 16) {
      final visibles = busStops.where((b) {
        return b.lat >= bounds.southwest.latitude &&
            b.lat <= bounds.northeast.latitude &&
            b.lng >= bounds.southwest.longitude &&
            b.lng <= bounds.northeast.longitude;
      }).toList();

      final newMarkers = visibles
          .map(
            (b) => Marker(
                markerId: MarkerId('${b.lat},${b.lng}'),
                position: LatLng(b.lat, b.lng),
                infoWindow: InfoWindow(title: b.codDftrans),
                icon: customIcon,
                onTap: () {
                  showModalBottomSheet(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      context: context,
                      builder: (context) {
                        return BusStopLinesBottomSheet(
                          busStopId: b.codDftrans,
                        );
                      });
                }),
          )
          .toSet();
      setState(() {
        _markers = newMarkers;
      });
    } else {
      setState(() {
        _markers.clear();
      });
    }
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

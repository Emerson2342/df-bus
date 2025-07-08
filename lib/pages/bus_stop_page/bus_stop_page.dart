import 'dart:async';
import 'dart:convert';

import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/models/bus_stop.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:markers_cluster_google_maps_flutter/markers_cluster_google_maps_flutter.dart';

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
  final ClusterManagerId clusterId = const ClusterManagerId('busStopCluster');

  late MarkersClusterManager _clusterManager;

  double _currentZoom = 12.0;

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

    for (var i = 0; i < busStops.length; i++) {
      final stop = busStops[i];
      _clusterManager.addMarker(Marker(
        markerId: MarkerId(stop.codDftrans),
        position: LatLng(stop.lat, stop.lng),
        infoWindow: InfoWindow(title: 'Parada ${stop.codDftrans}'),
      ));
    }

    await _clusterManager.updateClusters(zoomLevel: _currentZoom);
    setState(() {});
  }

  Future<void> _updateClusters() async {
    await _clusterManager.updateClusters(zoomLevel: _currentZoom);
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    debugPrint("********************** Mapa Page");
    _loadCustomIcon();
    _loadBusStops();
    _clusterManager = MarkersClusterManager(
      clusterMarkerSize: 20,
      clusterColor: Colors.blue,
      clusterBorderThickness: 2,
      clusterBorderColor: Colors.blue[900]!,
      clusterOpacity: 1,
      clusterTextStyle: const TextStyle(fontSize: 10, color: Colors.white),
      onMarkerTap: (LatLng position) {
        debugPrint('Id da parada - $position');
      },
    );
    rootBundle.loadString('assets/maps/map_style_dark.json').then((string) {
      if (!themeNotifier.isDarkMode) return;
      setState(() {
        _mapStyle = string;
      });
    });
    super.initState();
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
                initialCameraPosition: CameraPosition(
                  target: LatLng(-15.7942, -47.8822),
                  zoom: 14,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  _updateClusters();
                },
                style: _mapStyle,
                markers: Set<Marker>.of(_clusterManager.getClusteredMarkers()),
                onCameraMove: (position) {
                  _currentZoom = position.zoom;
                  // await _updateClusters();
                },
                onCameraIdle: () async {
                  await _updateClusters();
                },
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

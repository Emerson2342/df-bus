import 'dart:async';

import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/helpers/position_widget.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsWidget extends StatefulWidget {
  const MapsWidget({super.key, required this.busRoute});

  final List<int> busRoute;

  @override
  State<MapsWidget> createState() => MapsWidgetState();
}

class MapsWidgetState extends State<MapsWidget> {
  late Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  final searchLineController = getIt<SearchLineController>();

  final List<FeatureBusRoute> _busRoute = [];

  Set<Marker> markes = {};

  Set<Polyline> _polylines = {};

  List<List<LatLng>> pointsOnMap = [
    [
      const LatLng(-15.832316, -47.921930),
      const LatLng(-15.831514, -47.920686),
      const LatLng(-15.830901, -47.919866),
      const LatLng(-15.830242, -47.918991),
      const LatLng(-15.828163, -47.916076),
    ],
    [
      const LatLng(-15.831439, -47.921952),
      const LatLng(-15.831335, -47.921834),
      const LatLng(-15.831181, -47.921587),
      const LatLng(-15.830252, -47.920327),
      const LatLng(-15.829725, -47.919651),
    ]
  ];

  Position? _currentPosition;
  CameraPosition _initialCameraPosition =
      CameraPosition(target: LatLng(-15.793112, -47.884543), zoom: 15);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getBusroute();
    initMarkers();
  }

  void initMarkers() async {
    final newMarkers = <Marker>{};
    final newPolylines = <Polyline>{};
    for (int i = 0; i < pointsOnMap.length; i++) {
      for (int j = 0; j < pointsOnMap[i].length; j++) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('$i-$j'),
            position: pointsOnMap[i][j],
            infoWindow: const InfoWindow(title: "Title", snippet: "Snippet"),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      }
      newPolylines.add(
        Polyline(
          polylineId: PolylineId('polyline-$i'),
          points: pointsOnMap[i],
          color: i == 0
              ? const Color.fromARGB(255, 41, 3, 255)
              : const Color.fromARGB(255, 222, 82, 12),
          // width: 3,
        ),
      );
    }
    setState(() {
      markes = newMarkers;
      _polylines = newPolylines;
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
  }

  Future<void> _getBusroute() async {
    for (var item in widget.busRoute) {
      debugPrint("*********Código da rota $item");
    }
    for (final route in widget.busRoute) {
      final busRoute = await searchLineController.getBusRoute(route.toString());

      _busRoute.add(busRoute);
    }
    if (!mounted) return;

    setState(() {});
    debugPrint("*********Quantidade de rotas ${_busRoute.length}");
    for (final r in _busRoute) {
      debugPrint("*********${r.features[0].geometry.coordinates[0]}");
    }
    await setInitialCamera(mapController, _polylines);
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await determinePosition();

      debugPrint(
          '*******Lat: ${position.latitude}, Long: ${position.longitude}');
      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.4746,
        );
      });

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_currentPosition != null)
            Text(
              'Lat: ${_currentPosition!.latitude}, Long: ${_currentPosition!.longitude}',
            )
          else
            const CircularProgressIndicator(),
          Expanded(
            child: GoogleMap(
              polylines: _polylines,
              myLocationEnabled: true,
              mapType: MapType.normal,
              trafficEnabled: true,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                mapController.complete(controller);
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}

import 'dart:async';

import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/helpers/position_widget.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsWidget extends StatefulWidget {
  const MapsWidget({super.key, required this.busLine});

  final String busLine;

  @override
  State<MapsWidget> createState() => MapsWidgetState();
}

class MapsWidgetState extends State<MapsWidget> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final searchLineController = getIt<SearchLineController>();

  FeatureBusRoute? _busRoute;

  Position? _currentPosition;
  CameraPosition _initialCameraPosition =
      CameraPosition(target: LatLng(-15.793112, -47.884543), zoom: 15);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getBusroute();
  }

  Future<void> _getBusroute() async {
    final busRoute = await searchLineController.getBusRoute(widget.busLine);
    setState(() {
      _busRoute = busRoute;
    });
    debugPrint("*********${busRoute.type}");
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

  // static const CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

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
              myLocationEnabled: true,
              mapType: MapType.normal,
              trafficEnabled: true,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
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

import 'dart:async';

import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

import 'package:intl/intl.dart';

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

  final List<FeatureBusRoute> _busRoute = [];
  Set<Marker> markes = {};

  Set<Polyline> _polylines = {};

  List<List<LatLng>> pointsOnMap = [];
  late Timer _timer;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  String? _mapStyle;

  //Position? _currentPosition;
  final CameraPosition _initialCameraPosition =
      CameraPosition(target: LatLng(-15.793112, -47.884543), zoom: 15);

  @override
  void initState() {
    // _setMapStyle();
    rootBundle.loadString('assets/maps/map_style_dark.json').then((string) {
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
    _busRoute.clear();
    pointsOnMap.clear();
    _polylines.clear();
    markes.clear();
    _timer.cancel();
    super.dispose();
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
    await _getBusLocation();
    //await _getCurrentLocation();
    await _getBusroute();
    _initMarkers();
    if (mounted) {
      setState(() {});
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_polylines.isNotEmpty) {
        await setInitialCamera(mapController, _polylines);
      }
    });
  }

  void _initMarkers() {
    final newPolylines = <Polyline>{};
    for (int i = 0; i < pointsOnMap.length; i++) {
      newPolylines.add(
        Polyline(
          polylineId: PolylineId('polyline-$i'),
          points: pointsOnMap[i],
          color: i == 0
              ? const Color.fromARGB(255, 82, 55, 232)
              : const Color.fromARGB(255, 45, 156, 65),
          width: 3,
        ),
      );
    }
    if (!mounted) return;
    // setState(() {
    _polylines = newPolylines;
    // });
  }

  Future<void> _getBusLocation() async {
    debugPrint("***************Chamou a localização dos ônibus");
    final newMarkers = <Marker>{};
    final geoLocation =
        await searchLineController.getBusLocation(widget.busLine);
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
    if (!mounted) return;
    double sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
    for (final route in widget.busRoute) {
      final busRoute = await searchLineController.getBusRoute(route.toString());

      _busRoute.add(busRoute);
    }

    // setState(() {});
    debugPrint("*********Quantidade de rotas ${_busRoute.length}");

    for (final feature in _busRoute) {
      for (final f in feature.features) {
        final List<LatLng> singleRoute = f.geometry.coordinates.map((coord) {
          final x = coord[0];
          final y = coord[1];

          final lon = x * 180 / 20037508.34;
          final lat =
              (math.atan(sinh(y / 20037508.34 * math.pi)) * 180) / math.pi;

          return LatLng(lat, lon);
        }).toList();
        pointsOnMap.add(singleRoute);
      }
    }
  }

  // Future<void> _getCurrentLocation() async {
  //   try {
  //     final position = await determinePosition();

  //     debugPrint(
  //         '*******Lat: ${position.latitude}, Long: ${position.longitude}');
  //     setState(() {
  //       _initialCameraPosition = CameraPosition(
  //         target: LatLng(position.latitude, position.longitude),
  //         zoom: 14.4746,
  //       );
  //     });

  //     // setState(() {
  //     // _currentPosition = position;
  //     //  });
  //   } catch (e) {
  //     debugPrint('Erro ao obter localização: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              polylines: _polylines,
              myLocationEnabled: true,
              mapType: MapType.normal,
              markers: markes,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                mapController.complete(controller);
              },
              style: _mapStyle,
            ),
          ),
          AdsBannerWidget(),
        ],
      ),
    );
  }
}

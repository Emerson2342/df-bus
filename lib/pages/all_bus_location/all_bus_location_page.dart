import 'dart:async';
import 'dart:convert';

import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/controller/storage_controller.dart';
import 'package:df_bus/helpers/position_widget.dart';
import 'package:df_bus/models/bus_location.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/models/bus_stop.dart';
import 'package:df_bus/pages/all_bus_location/widgets/bus_stop_lines_bottom_sheet.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:df_bus/widgets/snackbar_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusStopPage extends StatefulWidget {
  const BusStopPage({super.key});

  @override
  State<BusStopPage> createState() => _BusStopPageState();
}

class _BusStopPageState extends State<BusStopPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final searchLineController = getIt<SearchLineController>();
  final storageController = getIt<StorageController>();

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
  bool showBusStops = false;

  List<BusStop> busStops = [];
  List<AllBusLocation> allBusLocation = [];
  List<FeatureRoute> _busRoute = [];
  List<LatLng> pointsOnMap = [];
  Set<Polyline> _polylines = {};
  Timer? _timer;
  final originIdNotifier =
      getIt<ValueNotifier<String>>(instanceName: 'originId');
  final destIdNotifier = getIt<ValueNotifier<String>>(instanceName: 'destId');

  @override
  void initState() {
    debugPrint("********************** Mapa Page");
    _timer?.cancel();
    _loadCustomIcon();
    _myCameraPosition = CameraPosition(
      target: LatLng(-15.7942, -47.8822),
      zoom: 15,
    );
    _init();
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _loadAllBusLocation();
    });
    rootBundle
        .loadString(themeNotifier.isDarkMode
            ? 'assets/maps/map_style_dark.json'
            : 'assets/maps/map_style_light.json')
        .then((string) {
      setState(() {
        _mapStyle = string;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _busRoute.clear();
    _timer?.cancel();
    super.dispose();
    debugPrint("++++++++++++++Saiu da tela do mapa+++++++++++++");
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

  Future<void> _loadBusStops() async {
    final String jsonString =
        await rootBundle.loadString('assets/bus_stop/bus_stop.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    busStops = jsonData.map((e) => BusStop.fromJson(e)).toList();
    debugPrint(
        "Quantidade de parada de ônibus - ${busStops.length.toString()}");
  }

  Future<void> _loadAllBusLocation() async {
    try {
      final allLocation = await searchLineController.getAllBusLocation();
      setState(() {
        loadingAllBusLocation = false;
        allBusLocation = allLocation;
      });
    } catch (e) {
      if (!mounted) return;
      messageSnackbar(
          context, "Não foi possível buscar a localização dos ônibus.");
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
        zoom: 15,
      );
    });
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_myCameraPosition));
  }

  Future<void> _getBusRoute(Veiculo bus) async {
    _busRoute.clear();
    pointsOnMap.clear();
    if (!mounted) return;

    final hasSaved = await storageController.isAlreadySaved(bus.linha);

    if (hasSaved) {
      _busRoute = await storageController.getBusRoute(bus.linha);
    } else {
      _busRoute = await searchLineController.getBusRoute(bus.linha);
      for (final route in _busRoute) {
        await storageController.addBusRoute(route);
      }
    }

    for (final feature in _busRoute) {
      final coords = feature.geometry.coordinates;

      if (feature.properties.sentido == bus.sentido ||
          feature.properties.sentido == "CIRCULAR") {
        final List<LatLng> singleRoute = coords.map<LatLng>((coord) {
          final lat = coord[1];
          final lng = coord[0];
          return LatLng(lat, lng);
        }).toList();
        pointsOnMap = singleRoute;
      }
    }
    _busRoutePolyline();
  }

  void _busRoutePolyline() {
    final newPolylines = <Polyline>{};

    newPolylines.add(
      Polyline(
        polylineId: PolylineId('polyline'),
        points: pointsOnMap,
        color: Colors.amber,
        width: 2,
      ),
    );

    if (!mounted) return;
    // setState(() {
    _polylines = newPolylines;
    // });
  }

  void _onCameraIdle() async {
    final controller = await _controller.future;
    final zoom = await controller.getZoomLevel();
    final bounds = await controller.getVisibleRegion();
    final Set<Marker> newMarkers = {};
    final List<Veiculo> allBus = [];

    BitmapDescriptor ccustomIcon;
    debugPrint(">>>>>>>>>>>>>>>>>Zoom $zoom");
    if (zoom >= 15) {
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
          ccustomIcon = bsBusIcon;
        }

        final allBus = item.veiculos.where((b) {
          return b.localizacao.latitude >= bounds.southwest.latitude &&
              b.localizacao.latitude <= bounds.northeast.latitude &&
              b.localizacao.longitude >= bounds.southwest.longitude &&
              b.localizacao.longitude <= bounds.northeast.longitude;
        });

        newMarkers.addAll(
          allBus.map(
            (b) => Marker(
                markerId: MarkerId(
                    '${b.localizacao.latitude},${b.localizacao.longitude}'),
                position:
                    LatLng(b.localizacao.latitude, b.localizacao.longitude),
                infoWindow: InfoWindow(title: b.linha),
                onTap: () async {
                  await _getBusRoute(b);
                },
                icon: ccustomIcon),
          ),
        );
      }
    }

    if (zoom >= 15) {
      final visibles = busStops.where((b) {
        return b.lat >= bounds.southwest.latitude &&
            b.lat <= bounds.northeast.latitude &&
            b.lng >= bounds.southwest.longitude &&
            b.lng <= bounds.northeast.longitude;
      }).toList();

      for (final item in allBusLocation) {
        for (final b in item.veiculos) {
          allBus.add(b);
        }
      }
      if (showBusStops) {
        newMarkers.addAll(visibles.map((b) {
          return Marker(
            markerId: MarkerId('${b.lat},${b.lng}'),
            position: LatLng(b.lat, b.lng),
            icon: customIcon,
            onTap: () {
              if (originIdNotifier.value.isEmpty) {
                originIdNotifier.value = b.codDftrans;
              } else {
                destIdNotifier.value = b.codDftrans;
              }
              if (originIdNotifier.value.isNotEmpty &&
                  destIdNotifier.value.isNotEmpty) {
                showModalBottomSheet(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  context: context,
                  builder: (context) {
                    return BusStopLinesBottomSheet(
                      allBuslocation: allBus,
                    );
                  },
                );
              }
            },
          );
        }));
      }

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
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GoogleMap(
                      polylines: _polylines,
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      initialCameraPosition: _myCameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        // _updateClusters();
                      },
                      onTap: (_) {
                        setState(() {
                          _polylines.clear();
                        });
                      },
                      style: _mapStyle,
                      markers: _markers,
                      onCameraMove: (_) {},
                      onCameraIdle: _onCameraIdle,
                      compassEnabled: true,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 0,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: showBusStops,
                              checkColor: Colors.amber,
                              activeColor: Colors.transparent,
                              onChanged: (value) {
                                setState(() {
                                  showBusStops = value!;
                                  _onCameraIdle();
                                });
                              },
                            ),
                            const Text('Mostrar paradas de ônibus',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber)),
                          ],
                        ),
                        Visibility(
                          visible: originIdNotifier.value.isNotEmpty,
                          child: const Row(
                            children: [
                              Icon(Icons.check),
                              Text(
                                'Parada de origem selecionada',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: destIdNotifier.value.isNotEmpty,
                          child: const Row(
                            children: [
                              Icon(Icons.check),
                              Text(
                                'Parada de destino selecionada',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            AdsBannerWidget()
          ],
        ),
      ),
    );
  }
}

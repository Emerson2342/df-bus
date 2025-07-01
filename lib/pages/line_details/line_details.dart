import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/pages/line_details/widgets/header_widget.dart';
import 'package:df_bus/pages/line_details/widgets/maps_widget.dart';
import 'package:df_bus/pages/line_details/widgets/schedule_details_bottom_sheet.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineDetailsWidget extends StatefulWidget {
  const LineDetailsWidget({super.key, required this.busLine});

  final String busLine;

  @override
  State<LineDetailsWidget> createState() => _LineDetailsWidgetState();
}

class _LineDetailsWidgetState extends State<LineDetailsWidget> {
  final searchLineController = getIt<SearchLineController>();
  List<BusSchedule> busSchedule = [];
  List<int> busRoutes = [];
  List<BusDirection> busDirections = [];

  @override
  void initState() {
    super.initState();
    _loadBusSchedule();
    _loadBusDirection();
    registerLineDetails();
  }

  void registerLineDetails() {
    final now = DateTime.now();

    final dayWeek = DateFormat('EEEE').format(now);
    final timeFormatted = DateFormat('HH:mm').format(now);

    FirebaseAnalytics.instance.logEvent(
      name: 'line_details_screen',
      parameters: {
        'linha': widget.busLine,
        'dia': dayWeek,
        'hora': timeFormatted,
      },
    );
  }

  _loadBusSchedule() async {
    var busSc = await searchLineController.getBusSchedule(widget.busLine);
    setState(() {
      busSchedule = busSc;
    });
  }

  _loadBusDirection() async {
    var busDir = await searchLineController.getBusDirection(widget.busLine);
    setState(() {
      busDirections = busDir;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Linha ${widget.busLine}",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 150),
        child: FloatingActionButton(
          backgroundColor: Colors.white70,
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ScheduleDetails(
                    busLineSchedule: busSchedule,
                    busDirections: busDirections,
                  );
                });
          },
          child: Icon(
            Icons.schedule,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder(
        future: searchLineController.getBusDetails(widget.busLine),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Ops...Erro ao buscar a linha ${widget.busLine}");
          }
          final lineDetails = snapshot.data!;
          for (var item in lineDetails) {
            busRoutes.add(item.sequencial);
          }
          for (var item in busRoutes) {
            debugPrint("*********Código da rota Main $item");
          }
          return Stack(
            children: [
              Positioned.fill(
                child: MapsWidget(
                  busRoute: busRoutes,
                  busLine: widget.busLine,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: HeaderWidget(lineDetails: lineDetails[0]),
              ),
            ],
          );
        },
      ),
    );
  }
}

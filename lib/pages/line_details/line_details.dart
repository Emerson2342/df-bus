import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/line_details/widgets/header_widget.dart';
import 'package:df_bus/pages/line_details/widgets/maps_widget.dart';
import 'package:df_bus/pages/line_details/widgets/schedule_details_bottom_sheet.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/widgets/progress_indicator_widget.dart';
import 'package:flutter/material.dart';

class LineDetailsWidget extends StatefulWidget {
  const LineDetailsWidget({super.key, required this.busLine});

  final String busLine;

  @override
  State<LineDetailsWidget> createState() => _LineDetailsWidgetState();
}

class _LineDetailsWidgetState extends State<LineDetailsWidget> {
  final searchLineController = getIt<SearchLineController>();
  List<BusSchedule> busSchedule = [];

  @override
  void initState() {
    super.initState();
    _loadBusSchedule();
  }

  _loadBusSchedule() async {
    var busSc = await searchLineController.getBusSchedule(widget.busLine);
    setState(() {
      busSchedule = busSc;
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
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          backgroundColor: Colors.white70,
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ScheduleDetails(busLineSchedule: busSchedule);
                });
          },
          child: Icon(
            Icons.schedule,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            FutureBuilder(
              future: searchLineController.getBusDetails(widget.busLine),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ProgressIndicatorWidget();
                } else if (snapshot.hasError) {
                  return Text("Ops...Erro ao buscar a linha ${widget.busLine}");
                }
                final lineDetails = snapshot.data!;
                return Container(
                  margin: const EdgeInsets.all(6),
                  child: HeaderWidget(lineDetails: lineDetails[0]),
                );
              },
            ),
            Expanded(
              // height: 350,
              //width: double.infinity,
              child: MapsWidget(
                busLine: widget.busLine,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

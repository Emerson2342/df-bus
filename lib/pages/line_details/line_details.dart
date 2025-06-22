import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/line_details/widgets/header_widget.dart';
import 'package:df_bus/pages/line_details/widgets/maps_widget.dart';
import 'package:df_bus/pages/line_details/widgets/schedule_list.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLineDetails();
  }

  void _loadLineDetails() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Linha ${widget.busLine}",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   child: const Icon(Icons.map),
        // ),
        body: Expanded(
          child: MapsWidget(),
        )
        /* Column(
        children: [
          FutureBuilder(
            future: searchLineController.getBusDetails(widget.busLine),
            builder: (context, snapshop) {
              if (snapshop.connectionState == ConnectionState.waiting) {
                return const ProgressIndicatorWidget();
              } else if (snapshop.hasError) {
                return Text("Ops...Erro ao buscar a linha ${widget.busLine}");
              }
              final lineDetails = snapshop.data!;
              return Column(
                children: [
                  Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.all(6),
                          child: HeaderWidget(lineDetails: lineDetails[0]))
                    ],
                  )
                ],
              );
            },
          ),
          FutureBuilder(
            future: searchLineController.getBusSchedule(widget.busLine),
            builder: (context, snapshop) {
              if (snapshop.connectionState == ConnectionState.waiting) {
                return const ProgressIndicatorWidget();
              } else if (snapshop.hasError) {
                return Text(
                    "Ops...Erro ao buscar os horários linha ${widget.busLine}");
              }
              final lineSchedule = snapshop.data!;

              final List<String> sentidos =
                  lineSchedule.map((s) => s.sentido).toSet().toList();

              final Map<String, List<BusSchedule>> schedulesBySentido = {};
              for (final s in lineSchedule) {
                schedulesBySentido.putIfAbsent(s.sentido, () => []).add(s);
              }

              // return//
              return DefaultTabController(
                length: sentidos.length,
                child: Column(
                  children: [
                    TabBar(
                      tabs: sentidos
                          .map((sentido) => Tab(text: sentido))
                          .toList(),
                    ),
                    Expanded(
                      flex: 3,
                      child: TabBarView(
                        children: sentidos.map((sentido) {
                          final schedules = schedulesBySentido[sentido] ?? [];
                          return ScheduleListView(schedules: schedules);
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      width: 150,
                      child: MapsWidget(),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),*/
        );
  }
}

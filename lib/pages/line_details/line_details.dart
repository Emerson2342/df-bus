import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/pages/line_details/widgets/header_widget.dart';
import 'package:df_bus/pages/line_details/widgets/maps_widget.dart';
import 'package:df_bus/pages/line_details/widgets/schedule_details_bottom_sheet.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/line_details_notifier.dart';
import 'package:flutter/material.dart';

class LineDetailsWidget extends StatefulWidget {
  const LineDetailsWidget({super.key});

  @override
  State<LineDetailsWidget> createState() => _LineDetailsWidgetState();
}

class _LineDetailsWidgetState extends State<LineDetailsWidget> {
  final searchLineController = getIt<SearchLineController>();
  final busLineNotifier = getIt<BusLineNotifier>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Linha ${busLineNotifier.value}",
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
          onPressed: () async {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ScheduleDetails();
                });
          },
          child: Icon(
            Icons.schedule,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder(
        future: searchLineController.getBusDetails(busLineNotifier.value),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            );
          } else if (snapshot.hasError) {
            return Text(
                "Ops...Erro ao buscar a linha ${busLineNotifier.value}");
          }
          final lineDetails = snapshot.data!;
          //busRoutes = [];

          return Column(
            children: [
              HeaderWidget(lineDetails: lineDetails[0]),
              Expanded(
                child: MapsWidget(),
              ),
            ],
          );
        },
      ),
    );
  }
}

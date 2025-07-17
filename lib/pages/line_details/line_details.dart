import 'package:df_bus/pages/line_details/widgets/header_widget.dart';
import 'package:df_bus/pages/line_details/widgets/maps_widget.dart';
import 'package:df_bus/pages/line_details/widgets/schedule_details_bottom_sheet.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/line_details_notifier.dart';
import 'package:df_bus/value_notifiers/show_maps_notifier.dart';
import 'package:flutter/material.dart';

class LineDetailsWidget extends StatefulWidget {
  const LineDetailsWidget({super.key});

  @override
  State<LineDetailsWidget> createState() => _LineDetailsWidgetState();
}

class _LineDetailsWidgetState extends State<LineDetailsWidget> {
  final busLineNotifier = getIt<BusLineNotifier>();
  final loadingBusDetailsNotifier = getIt<LoadingBusDetailsNotifier>();
  final showLineDetailsNotifier = getIt<ShowLineDetailsMapsNotifier>();

  @override
  void initState() {
    debugPrint(">>>>>>>>Entrou na tela LINE DETAILS");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            showLineDetailsNotifier.setShowLineDetails(false);
          },
        ),
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
      body: ValueListenableBuilder<bool>(
        valueListenable: loadingBusDetailsNotifier,
        builder: (context, isLoading, child) {
          return IndexedStack(
            index: isLoading ? 0 : 1,
            children: [
              Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Column(
                children: [
                  HeaderWidget(),
                  Expanded(
                    child: MapsWidget(),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}

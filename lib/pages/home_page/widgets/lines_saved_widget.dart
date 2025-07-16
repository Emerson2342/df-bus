import 'package:df_bus/controller/storage_controller.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/line_details_notifier.dart';
import 'package:df_bus/value_notifiers/show_maps_notifier.dart';
import 'package:flutter/material.dart';

class LinesSaved extends StatefulWidget {
  const LinesSaved({super.key});

  @override
  State<LinesSaved> createState() => LinesSavedState();
}

class LinesSavedState extends State<LinesSaved> {
  List<String> linesSaved = [];
  final storageController = getIt<StorageController>();
  final busLineNotifier = getIt<BusLineNotifier>();
  final showLineDetailsNotifier = getIt<ShowLineDetailsMapsNotifier>();
  @override
  void initState() {
    getLinesSaved();
    super.initState();
  }

  void getLinesSaved() async {
    final lines = await storageController.init();
    linesSaved = lines;
    debugPrint("*************linhas salvas");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Últimas Buscas",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        linesSaved.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text("Nenhuma busca recente"),
              )
            : Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  ...linesSaved.map(
                    (lineSaved) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 8 * 3) / 4,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              //  backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                              backgroundColor: Colors.amber),
                          // Color(0xff9dcbf9),
                          onLongPress: () async {
                            await storageController.removeLine(lineSaved);
                            getLinesSaved();
                          },
                          onPressed: () async {
                            busLineNotifier.setBusLine(lineSaved);
                            searchLineController.getBusDetails(lineSaved);
                            showLineDetailsNotifier.setShowLineDetails(true);
                            await storageController.addLine(lineSaved);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.directions_bus,
                                // color: Colors.white,
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              Text(
                                lineSaved,
                                // style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ],
    );
  }
}

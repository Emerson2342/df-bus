import 'package:df_bus/controller/storage_controller.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/line_details_notifier.dart';
import 'package:df_bus/value_notifiers/lines_saved_notifier.dart';
import 'package:df_bus/value_notifiers/show_maps_notifier.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';

class LinesSaved extends StatefulWidget {
  const LinesSaved({super.key});

  @override
  State<LinesSaved> createState() => LinesSavedState();
}

class LinesSavedState extends State<LinesSaved> {
  final storageController = getIt<StorageController>();
  final busLineNotifier = getIt<BusLineNotifier>();
  final showLineDetailsNotifier = getIt<ShowLineDetailsMapsNotifier>();
  final linesSavedNotifier = getIt<LinesSavedNotifier>();
  final themeNotifier = getIt<ThemeNotifier>();
  @override
  void initState() {
    getLinesSaved();
    super.initState();
  }

  void getLinesSaved() async {
    await storageController.getLines();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = themeNotifier.isDarkMode
        ? Colors.amber
        : Theme.of(context).colorScheme.primary;
    final textColor = themeNotifier.isDarkMode
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.tertiary;
    return ValueListenableBuilder(
        valueListenable: linesSavedNotifier,
        builder: (context, linesSaved, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Últimas Buscas",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
                              width:
                                  (MediaQuery.of(context).size.width - 8 * 3) /
                                      5,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    //  backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                                    backgroundColor: backgroundColor),
                                // Color(0xff9dcbf9),
                                onLongPress: () async {
                                  await storageController.removeLine(lineSaved);
                                  getLinesSaved();
                                },
                                onPressed: () async {
                                  busLineNotifier.setBusLine(lineSaved);
                                  searchLineController.getBusDetails(lineSaved);
                                  showLineDetailsNotifier
                                      .setShowLineDetails(true);
                                  await storageController.addLine(lineSaved);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.directions_bus,
                                      color: textColor,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      lineSaved,
                                      style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold),
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
        });
  }
}

import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/line_details/widgets/schedule_list.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/line_details_notifier.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';

class ScheduleDetails extends StatelessWidget {
  const ScheduleDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = getIt<ThemeNotifier>();
    final busScheduleNotifier = getIt<BusScheduleNotifier>();
    final busDirectionNotifier = getIt<BusDirectionNotifier>();
    final List<String> sentidos =
        busDirectionNotifier.value.map((s) => s.sentido).toSet().toList();
    final Map<String, List<BusSchedule>> schedulesBySentido = {};
    for (final s in busScheduleNotifier.value) {
      schedulesBySentido.putIfAbsent(s.sentido, () => []).add(s);
    }
    return Column(children: [
      Expanded(
        child: DefaultTabController(
          length: sentidos.length,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              border: Border.all(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
              ),
            ),
            child: Column(
              children: [
                TabBar(
                  labelStyle: TextStyle(
                      color: themeNotifier.isDarkMode
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      fontFamily: 'QuickSand',
                      fontWeight: FontWeight.bold),
                  tabs: sentidos.map((sentido) => Tab(text: sentido)).toList(),
                ),
                Expanded(
                  flex: 3,
                  child: TabBarView(children: [
                    ...sentidos.map((sentido) {
                      final schedules = schedulesBySentido[sentido] ?? [];
                      final busDirection = busDirectionNotifier.value
                          .firstWhere((d) => d.sentido == sentido);
                      return ScheduleListView(
                        schedules: schedules,
                        busDirection: busDirection,
                      );
                    }),
                  ]),
                ),
              ],
            ),
          ),
        ),
      )
    ]);
  }
}


/*
*/
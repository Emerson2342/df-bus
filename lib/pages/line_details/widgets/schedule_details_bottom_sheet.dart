import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/line_details/widgets/schedule_list.dart';
import 'package:flutter/material.dart';

class ScheduleDetails extends StatelessWidget {
  const ScheduleDetails({super.key, required this.busLineSchedule});

  final List<BusSchedule> busLineSchedule;

  @override
  Widget build(BuildContext context) {
    final List<String> sentidos =
        busLineSchedule.map((s) => s.sentido).toSet().toList();
    final Map<String, List<BusSchedule>> schedulesBySentido = {};
    for (final s in busLineSchedule) {
      schedulesBySentido.putIfAbsent(s.sentido, () => []).add(s);
    }
    return Column(children: [
      Expanded(
        child: DefaultTabController(
          length: sentidos.length,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23))),
            child: Column(
              children: [
                TabBar(
                  labelStyle: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'QuickSand',
                      fontWeight: FontWeight.bold),
                  tabs: sentidos.map((sentido) => Tab(text: sentido)).toList(),
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
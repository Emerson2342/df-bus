import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:flutter/material.dart';

class ScheduleListView extends StatelessWidget {
  final List<BusSchedule> schedules;
  final BusDirection busDirection;

  const ScheduleListView(
      {required this.schedules, super.key, required this.busDirection});

  @override
  Widget build(BuildContext context) {
    final allSchedules = schedules.expand((s) => s.horarios).toList();

    final Map<String, List<Schedule>> porDia = {};
    for (final h in allSchedules) {
      porDia.putIfAbsent(h.diasLabel, () => []).add(h);
    }

    return ListView(padding: const EdgeInsets.all(8), children: [
      Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 5, right: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Origem: ${busDirection.origem}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 5, right: 5),
        child: Row(
          children: [
            Flexible(
              child: Text(
                "Destino: ${busDirection.destino}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
      ...porDia.keys.map((diaLabel) {
        final horariosDoDia = porDia[diaLabel]!;

        final manha = horariosDoDia.where((h) => h.hora < 12).toList();
        final tarde =
            horariosDoDia.where((h) => h.hora >= 12 && h.hora < 18).toList();
        final noite = horariosDoDia.where((h) => h.hora >= 18).toList();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          color: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    _labelDoDia(diaLabel),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (manha.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Manhã:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  _horariosRow(manha, context),
                ],
                if (tarde.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Tarde:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  _horariosRow(tarde, context),
                ],
                if (noite.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Noite:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  _horariosRow(noite, context),
                ],
              ],
            ),
          ),
        );
      })
    ]);
  }

  Widget _horariosRow(List<Schedule> horarios, BuildContext context) {
    horarios.sort((a, b) {
      final minutesA = a.hora * 60 + a.minuto;
      final minutesB = b.hora * 60 + b.minuto;
      return minutesA.compareTo(minutesB);
    });

    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: horarios.map((h) {
        final text =
            '${h.hora.toString().padLeft(2, '0')}:${h.minuto.toString().padLeft(2, '0')}';
        return Chip(
          label: Text(text),
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(5)),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        );
      }).toList(),
    );
  }

  String _labelDoDia(String diasLabel) {
    switch (diasLabel) {
      case 'SEG_SEX':
        return 'Segunda a Sexta';
      case 'SABADO':
        return 'Sábado';
      case 'DOMINGO':
        return 'Domingo';
      default:
        return diasLabel;
    }
  }
}

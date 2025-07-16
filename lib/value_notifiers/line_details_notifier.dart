import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final searchLineController = getIt<SearchLineController>();

class LoadingBusDetailsNotifier extends ValueNotifier<bool> {
  LoadingBusDetailsNotifier() : super(true);
  bool get loadinBusDetails => value;
  void setLoadingBusDetails(bool isLoading) {
    value = isLoading;
  }
}

class BusLineNotifier extends ValueNotifier<String> {
  BusLineNotifier() : super("");

  String get busLine => value;

  void setBusLine(String newLine) {
    value = newLine;
    registerLineDetails(value);
  }

  void registerLineDetails(String busLine) {
    final now = DateTime.now();

    final dayWeek = DateFormat('EEEE').format(now);
    final timeFormatted = DateFormat('HH:mm').format(now);

    FirebaseAnalytics.instance.logEvent(
      name: 'line_details_screen',
      parameters: {
        'linha': busLine,
        'dia': dayWeek,
        'hora': timeFormatted,
      },
    );
  }
}

class BusScheduleNotifier extends ValueNotifier<List<BusSchedule>> {
  BusScheduleNotifier() : super([]);

  List<BusSchedule> get busSchedule => value;

  setBusSchedule(List<BusSchedule> busSchedule) async {
    value = busSchedule;
  }
}

class BusDirectionNotifier extends ValueNotifier<List<BusDirection>> {
  BusDirectionNotifier() : super([]);

  List<BusDirection> get busDirection => value;

  setBusDirection(List<BusDirection> busDirection) {
    value = busDirection;
  }
}

class LineDetailsNotifier extends ValueNotifier<List<DetalheOnibus>> {
  LineDetailsNotifier() : super([]);

  List<DetalheOnibus> get lineDetails => value;

  setLineDetails(List<DetalheOnibus> lineDetails) {
    value = lineDetails;
  }
}

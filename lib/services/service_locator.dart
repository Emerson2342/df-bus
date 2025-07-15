import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/controller/storage_controller.dart';
import 'package:df_bus/services/bus_service.dart';
import 'package:df_bus/services/storage_service.dart';
import 'package:df_bus/storage/hive_storage.dart';
import 'package:df_bus/value_notifiers/line_details_notifier.dart';
import 'package:df_bus/value_notifiers/show_maps_notifier.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<StorageService>(() => HiveStorage());
  getIt.registerLazySingleton<BusService>(() => BusService());
  getIt.registerLazySingleton<SearchLineController>(
      () => SearchLineController());
  getIt.registerLazySingleton<StorageController>(() => StorageController());
  getIt.registerLazySingleton<ThemeNotifier>(() => ThemeNotifier());
  getIt.registerLazySingleton<ShowMapsNotifier>(() => ShowMapsNotifier());
  getIt.registerLazySingleton<ShowLineDetailsMapsNotifier>(
      () => ShowLineDetailsMapsNotifier());
  getIt.registerSingleton<ValueNotifier<String>>(ValueNotifier<String>(''),
      instanceName: 'destId');
  getIt.registerSingleton<ValueNotifier<String>>(ValueNotifier<String>(''),
      instanceName: 'originId');

  getIt.registerLazySingleton<BusLineNotifier>(() => BusLineNotifier());
  getIt.registerLazySingleton<BusScheduleNotifier>(() => BusScheduleNotifier());
  getIt.registerLazySingleton<BusDirectionNotifier>(
      () => BusDirectionNotifier());
  getIt.registerLazySingleton<LineDetailsNotifier>(() => LineDetailsNotifier());
}

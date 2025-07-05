import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/services/storage_service.dart';
import 'package:flutter/material.dart';

class ThemeNotifier extends ValueNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadDarkMode();
  }
  final storageService = getIt<StorageService>();

  bool get isDarkMode => value;

  Future<void> _loadDarkMode() async {
    final saved = await storageService.getDarkMode();
    value = saved;
  }

  Future<void> toggleDarkMode() async {
    value = !value;
    storageService.setDarkMode(value);
  }
}

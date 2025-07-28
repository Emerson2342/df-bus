import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/services.dart';

final themeNotifier = getIt<ThemeNotifier>();

Future<String> getMapstyle() {
  return rootBundle.loadString(
    themeNotifier.isDarkMode
        ? 'assets/maps/map_style_dark.json'
        : 'assets/maps/map_style_light.json',
  );
}

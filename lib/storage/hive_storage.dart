import 'dart:convert';

import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage extends StorageService {
  final String linesBoxName = "lines";
  final String darkModeBoxName = "isDarkMode";
  final String busRouteBoxName = "busRoutes";

  @override
  Future<List<String>> getLines() async {
    try {
      final linesBox = await Hive.openBox<String>(linesBoxName);
      final data = linesBox.values.cast<String>().toList();

      return data;
    } catch (e) {
      debugPrint("HIVE Storage - Erro ao buscar as linhas salvas - $e");
      rethrow;
    }
  }

  @override
  Future<void> saveLines(List<String> lines) async {
    try {
      final linesBox = await Hive.openBox<String>(linesBoxName);
      await linesBox.clear();

      for (final line in lines) {
        linesBox.add(line);
      }
    } catch (e) {
      debugPrint("HIVE Storage - Erro ao salvar as linhas - $e");
      rethrow;
    }
  }

  @override
  Future<void> addLine(String line) async {
    try {
      var lines = await getLines();
      lines.insert(0, line);
      lines = lines.toSet().toList();
      if (lines.length > 5) {
        lines = lines.sublist(0, 5);
      }
      await saveLines(lines);
    } catch (e) {
      debugPrint("HIVE Storage - Erro ao adicionar a linha $line - $e");
      rethrow;
    }
  }

  @override
  Future<void> removeLine(String line) async {
    try {
      var oldLines = await getLines();
      oldLines.remove(line);

      await saveLines(oldLines);
    } catch (e) {
      debugPrint("HIVE Storage - Erro ao remover a linha $line - $e");
      rethrow;
    }
  }

  @override
  Future<void> clearList() async {
    try {
      final linesBox = await Hive.openBox<String>(linesBoxName);
      await linesBox.clear();
    } catch (e) {
      debugPrint("HIVE Storage - Erro ao apagar a lista - $e");
      rethrow;
    }
  }

  @override
  Future<bool> getDarkMode() async {
    try {
      final darkModeBox = await Hive.openBox<bool>(darkModeBoxName);
      final isDark =
          darkModeBox.get(darkModeBoxName, defaultValue: false) ?? false;
      return isDark;
    } catch (e) {
      debugPrint("HIVE Storage - Erro ao buscar dados salvos MODO ESCURO - $e");
      rethrow;
    }
  }

  @override
  Future<void> setDarkMode(bool isDarkMode) async {
    try {
      final box = await Hive.openBox<bool>(darkModeBoxName);
      await box.put(darkModeBoxName, isDarkMode);
    } catch (e) {
      debugPrint('Erro ao salvar dark mode no Hive: $e');
      rethrow;
    }
  }

  @override
  Future<void> addBusRoute(FeatureRoute busRoute) async {
    try {
      final routeBox = await Hive.openBox<String>(busRouteBoxName);
      final key =
          '${busRoute.properties.codLinha}_${busRoute.properties.sentido}';
      final json = jsonEncode(busRoute.toJson());
      if (!routeBox.containsKey(key)) {
        if (routeBox.length >= 20) {
          final first = routeBox.keys.first;
          await routeBox.delete(first);
        }
      }

      await routeBox.put(key, json);
    } catch (e) {
      debugPrint(
          "HIVE Storage - Erro ao salvar a rota da linha ${busRoute.properties.codLinha} - $e");
      rethrow;
    }
  }

  @override
  Future<List<FeatureRoute>> getBusRoute(String busLine) async {
    try {
      final routeBox = await Hive.openBox<String>(busRouteBoxName);

      final results = routeBox.values
          .map((json) => FeatureRoute.fromJson(jsonDecode(json)))
          .where((route) => route.properties.codLinha == busLine)
          .toList();

      return results;
    } catch (e) {
      debugPrint("HIVE Storage - Erro ao buscar a rota da linha $busLine - $e");
      rethrow;
    }
  }
}

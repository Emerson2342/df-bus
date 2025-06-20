import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/services/bus_service.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/services/storage_service.dart';
import 'package:dio/dio.dart';

class SearchLineController {
  final storageService = getIt<StorageService>();
  final busService = getIt<BusService>();

  Future<List<String>> init() async {
    return await storageService.getLines();
  }

  Future<List<SearchLine>> searchLines(String linetoSeach) async {
    final response = await busService.searchLines(linetoSeach);
    return response;
  }

  Future<void> addLine(String line) async {
    await storageService.addLine(line);
  }

  Future<void> deleteLines() async {
    await storageService.clearList();
  }
}

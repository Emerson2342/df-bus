import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/services/storage_service.dart';

class StorageController {
  final storageService = getIt<StorageService>();
  Future<List<String>> init() async {
    return await storageService.getLines();
  }

  Future<void> addLine(String line) async {
    await storageService.addLine(line);
  }

  Future<void> removeLine(String line) async {
    await storageService.removeLine(line);
  }

  Future<void> deleteLines() async {
    await storageService.clearList();
  }

  Future<List<FeatureRoute>> getBusRoute(String busLine) async {
    return await storageService.getBusRoute(busLine);
  }

  Future<void> addBusRoute(FeatureRoute busRoute) async {
    await storageService.addBusRoute(busRoute);
  }

  Future<bool> isAlreadySaved(String busLine) async {
    final routes = await storageService.getBusRoute(busLine);
    return routes.isNotEmpty;
  }
}

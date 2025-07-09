import 'package:df_bus/models/bus_location.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/models/search_lines.dart';
import 'package:df_bus/services/bus_service.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/services/storage_service.dart';

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

  Future<void> removeLine(String line) async {
    await storageService.removeLine(line);
  }

  Future<void> deleteLines() async {
    await storageService.clearList();
  }

  Future<List<DetalheOnibus>> getBusDetails(String line) async {
    final details = await busService.getLineDetails(line);
    return details;
  }

  Future<List<BusSchedule>> getBusSchedule(String line) async {
    final schedule = await busService.getBusSchedule(line);
    return schedule;
  }

  Future<FeatureBusRoute> getBusRoute(String routeCod) async {
    final busRoute = await busService.getBusRoute(routeCod);
    return busRoute;
  }

  Future<FeatureBusLocation> getBusLocation(String line) async {
    final busLocation = await busService.getBusLocation(line);
    return busLocation;
  }

  Future<List<QuerySearch>> findByQuery(String query) async {
    final queryResult = await busService.findQuery(query);
    return queryResult;
  }

  Future<List<DetalheOnibus>> searchByRef(
      QuerySearch fromItem, QuerySearch toItem) async {
    final lines = await busService.searchByRef(fromItem, toItem);
    return lines;
  }

  Future<List<BusDirection>> getBusDirection(String busLine) async {
    final busDirection = await busService.getBusDirection(busLine);
    return busDirection;
  }

  Future<List<DetalheOnibus>> getBusStopLines(String id) async {
    final lines = await busService.getBusStopLines(id);
    return lines;
  }
}

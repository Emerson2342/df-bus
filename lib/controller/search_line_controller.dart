import 'package:df_bus/models/bus_location.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/models/search_lines.dart';
import 'package:df_bus/services/bus_service.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/line_details_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchLineController {
  final busService = getIt<BusService>();
  final lineDetailsNotifier = getIt<LineDetailsNotifier>();
  final busDirectionNotifier = getIt<BusDirectionNotifier>();
  final busLineNotifier = getIt<BusLineNotifier>();
  final busScheduleNotifier = getIt<BusScheduleNotifier>();
  final loadingBusDetailsNotifier = getIt<LoadingBusDetailsNotifier>();

  Future<List<SearchLine>> searchLines(String linetoSeach) async {
    try {
      final response = await busService.searchLines(linetoSeach);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getBusDetails(String busLine) async {
    try {
      loadingBusDetailsNotifier.setLoadingBusDetails(true);
      final details = await busService.getLineDetails(busLine);
      final busDirection = await busService.getBusDirection(busLine);
      final busSchedule = await busService.getBusSchedule(busLine);
      lineDetailsNotifier.setLineDetails(details);
      busLineNotifier.setBusLine(busLine);
      busDirectionNotifier.setBusDirection(busDirection);
      busScheduleNotifier.setBusSchedule(busSchedule);
      loadingBusDetailsNotifier.setLoadingBusDetails(false);
    } catch (e, stackTrace) {
      debugPrint('Erro ao buscar detalhes do ônibus: $e');
      debugPrint(stackTrace.toString());
    } finally {
      loadingBusDetailsNotifier.setLoadingBusDetails(false);
    }
  }

  Future<List<FeatureRoute>> getBusRoute(String line) async {
    try {
      final busRoute = await busService.getBusRoute(line);
      return busRoute;
    } catch (e, stackTrace) {
      debugPrint('Erro ao buscar a rota do ônibus: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<FeatureBusLocation?> getBusLocation(
      String line, BuildContext context) async {
    try {
      final busLocation = await busService.getBusLocation(line);
      return busLocation;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        if (!context.mounted) rethrow;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Ops.."),
                content: Text(
                    "Houve uma demora na busca da linha $line. Tente novamente mais tarde!"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Fechar"),
                  )
                ],
              );
            });
        return null;
      } else {
        rethrow;
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao buscar a localização do ônibus: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<List<QuerySearch>> findByQuery(String query) async {
    try {
      final queryResult = await busService.findQuery(query);
      return queryResult;
    } catch (e, stackTrace) {
      debugPrint('Erro ao buscar a query: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<List<DetalheOnibus>> searchByRef(
      QuerySearch fromItem, QuerySearch toItem) async {
    try {
      final lines = await busService.searchByRef(fromItem, toItem);
      return lines;
    } catch (e, stackTrace) {
      debugPrint('Erro ao buscar ônibus por referência: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<List<DetalheOnibus>> getBusStopLines(String bustopId) async {
    try {
      final lines = await busService.getBusStopLines(bustopId);
      return lines;
    } catch (e, stackTrace) {
      debugPrint('Erro ao buscar linhas da parada de ônibus: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<List<AllBusLocation>> getAllBusLocation() async {
    try {
      final allBusLocation = await busService.getAllBusLocation();
      return allBusLocation;
    } catch (e, stackTrace) {
      debugPrint('Erro ao buscar a localização de todos os ônibus: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}

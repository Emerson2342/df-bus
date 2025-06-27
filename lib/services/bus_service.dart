import 'dart:io';
import 'package:df_bus/models/bus_location.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/models/search_lines.dart';
import 'package:dio/io.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BusService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://www.sistemas.dftrans.df.gov.br/"),
  )..httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (
          X509Certificate cert,
          String host,
          int port,
        ) =>
            true;
        return client;
      },
    );

  Future<List<SearchLine>> searchLines(String linetoSeach) async {
    try {
      final response = await _dio.get("linha/find/$linetoSeach/20/short");
      return (response.data as List)
          .map((l) => SearchLine.fromJson(l))
          .toList();
    } catch (e, stacktrace) {
      debugPrint(
          "BusService - Erro ao buscar os resultados da linha $linetoSeach");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  Future<List<DetalheOnibus>> getLineDetails(String busLine) async {
    try {
      final response = await _dio.get("linha/numero/$busLine");
      return (response.data as List)
          .map((d) => DetalheOnibus.fromJson(d))
          .toList();
    } catch (e) {
      debugPrint("Erro ao buscar detalhes da linha $busLine");
      rethrow;
    }
  }

  Future<List<BusSchedule>> getBusSchedule(String busLine) async {
    try {
      final response = await _dio.get("horario/linha/numero/$busLine");
      return (response.data as List)
          .map((h) => BusSchedule.fromJson(h))
          .toList();
    } catch (e, stacktrace) {
      debugPrint("BusService - Erro ao buscar os horários da linha $busLine");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  Future<FeatureBusRoute> getBusRoute(String routeCod) async {
    try {
      final response = await _dio.get("percurso/linha/$routeCod");
      return FeatureBusRoute.fromJson(response.data);
    } catch (e, stacktrace) {
      debugPrint("BusService - Erro ao buscar a rota da linha $routeCod");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  Future<FeatureBusLocation> getBusLocation(String busLine) async {
    try {
      final response = await _dio.get("gps/linha/$busLine/geo/recent");
      return FeatureBusLocation.fromJson(response.data);
    } catch (e, stacktrace) {
      debugPrint(
          "BusService - Erro ao buscar a geolocalização da linha $busLine");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  Future<List<QuerySearch>> findQuery(String query) async {
    try {
      final response = await _dio.get("/referencia/find/$query/30?q=$query");
      return (response.data as List)
          .map((q) => QuerySearch.fromJson(q))
          .toList();
    } catch (e, stacktrace) {
      debugPrint("BusService - Erro ao pesquisar $query");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }
}

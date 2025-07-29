import 'dart:io';
import 'package:df_bus/models/bus_location.dart';
import 'package:df_bus/models/bus_route.dart';
import 'package:df_bus/models/search_lines.dart';
import 'package:dio/io.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BusService {
  late final Dio _dio;
  bool _initialized = false;

  Future<void> _initializeDioOnce() async {
    if (_initialized) return;

    final context = SecurityContext(withTrustedRoots: true);

    final certBytes = await rootBundle.load('assets/certs/dftrans.crt');
    context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());

    final httpClient = HttpClient(context: context);
    final adapter = IOHttpClientAdapter();
    adapter.createHttpClient = () => httpClient;

    _dio = Dio(
      BaseOptions(
          baseUrl: "https://www.sistemas.dftrans.df.gov.br/",
          connectTimeout: const Duration(seconds: 20)),
    );
    _dio.httpClientAdapter = adapter;

    _initialized = true;
  }

  Future<List<SearchLine>> searchLines(String linetoSeach) async {
    await _initializeDioOnce();
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
    await _initializeDioOnce();
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
    await _initializeDioOnce();
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

  Future<List<FeatureRoute>> getBusRoute(String busLine) async {
    debugPrint("***********************Buscou a rota do ônibus");
    await _initializeDioOnce();
    try {
      final response = await _dio.get("percurso/linha/numero/$busLine/WGS");

      return (response.data['features'] as List)
          .map((f) => FeatureRoute.fromJson(f))
          .toList();
    } catch (e, stacktrace) {
      debugPrint("BusService - Erro ao buscar a rota da linha $busLine");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  Future<FeatureBusLocation> getBusLocation(String busLine) async {
    await _initializeDioOnce();
    try {
      final response = await _dio.get(
        "gps/linha/$busLine/geo/recent",
      );
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
    await _initializeDioOnce();
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

  Future<List<DetalheOnibus>> searchByRef(
      QuerySearch fromItem, QuerySearch toItem) async {
    await _initializeDioOnce();
    try {
      final response = await _dio.get(
          "linha/${fromItem.tipo}/${fromItem.sequencialRef}/${toItem.tipo}/${toItem.sequencialRef}");

      debugPrint(response.requestOptions.uri.toString());

      return (response.data as List)
          .map((r) => DetalheOnibus.fromJson(r))
          .toList();
    } catch (e, stacktrace) {
      debugPrint("BusService - Erro ao pesquisar linhas por referência");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  Future<List<BusDirection>> getBusDirection(String busLine) async {
    await _initializeDioOnce();
    try {
      final response = await _dio.get("itinerario/linha/numero/$busLine");
      return (response.data as List)
          .map((r) => BusDirection.fromJson(r))
          .toList();
    } catch (e, stacktrace) {
      debugPrint(
          "BusService - Erro ao pesquisar o itinerário da linha $busLine");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  Future<List<DetalheOnibus>> getBusStopLines(String bustopId) async {
    await _initializeDioOnce();
    try {
      final response =
          await _dio.get("linha/paradacod/$bustopId/paradacod/$bustopId");
      return (response.data as List)
          .map((l) => DetalheOnibus.fromJson(l))
          .toList();
    } catch (e, stacktrace) {
      debugPrint(
          "BusService - Erro ao pesquisar os ônibus da parada: $bustopId");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }

  Future<List<AllBusLocation>> getAllBusLocation() async {
    await _initializeDioOnce();
    try {
      final response = await _dio.get("service/gps/operacoes");
      return (response.data as List)
          .map((b) => AllBusLocation.fromJson(b))
          .toList();
    } catch (e, stacktrace) {
      debugPrint(
          "BusService - Erro ao pesquisar a localização de todos os ônibus");
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
      rethrow;
    }
  }
}

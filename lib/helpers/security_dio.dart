import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Dio> createSecureDioClient() async {
  final context = SecurityContext(withTrustedRoots: true);

  final certBytes = await rootBundle.load('assets/certs/dftrans.crt');
  context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());

  final httpClient = HttpClient(context: context);
  final adapter = IOHttpClientAdapter();
  adapter.createHttpClient = () => httpClient;

  final dio = Dio();
  dio.httpClientAdapter = adapter;

  return dio;
}

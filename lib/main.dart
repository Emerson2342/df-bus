import 'package:df_bus/pages/home_page/home_page.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
void main() async {
  await Hive.initFlutter();
  setupGetIt();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      title: 'DF Bus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xff380b54),
          primary: Color(0xff380b54),
          secondary: Color(0xff7016a8),
        ),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

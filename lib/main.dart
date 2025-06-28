import 'package:df_bus/pages/home_page/home_page.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
void main() async {
  await Hive.initFlutter();
  setupGetIt();
  MobileAds.instance.initialize();
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
        fontFamily: 'QuickSand',
        inputDecorationTheme: InputDecorationTheme(
            // border: OutlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange)),
            floatingLabelStyle: TextStyle(color: Colors.white)),
        scaffoldBackgroundColor: Color(0xff011627),
        colorScheme: ColorScheme.dark(
            primary: Color(0xff010f1b),
            secondary: Color(0xff00bfff),
            tertiary: Color(0xff24415c)),
        useMaterial3: true,
      ),
      home: SafeArea(top: false, child: HomePage()),
    );
  }
}

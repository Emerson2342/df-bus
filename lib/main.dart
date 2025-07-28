import 'package:df_bus/firebase_options.dart';
import 'package:df_bus/pages/home_page/home_page.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  setupGetIt();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = getIt<ThemeNotifier>();
    return SafeArea(
      top: false,
      child: FutureBuilder(
          future: themeNotifier.init(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            }
            return ValueListenableBuilder<bool>(
                valueListenable: themeNotifier,
                builder: (context, isDarkMode, _) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'DF Bus',
                    theme: customLightTheme(),
                    darkTheme: customDarkTheme(),
                    themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                    home: UpgradeAlert(
                        upgrader:
                            Upgrader(countryCode: 'br', languageCode: 'pt'),
                        child: HomePage()),
                  );
                });
          }),
    );
  }
}

ThemeData customLightTheme() {
  return ThemeData(
    fontFamily: 'QuickSand',
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xff011f38)),
      ),
      floatingLabelStyle: TextStyle(color: Color(0xff011f38)),
    ),
    scaffoldBackgroundColor: Color(0xFFf5f5f5),
    //scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xff010f1b),
      primary: Color(0xff2f7bfe),
      secondary: Color(0xff011f38),
      tertiary: Colors.white,
    ),
    useMaterial3: true,
  );
}

ThemeData customDarkTheme() {
  return ThemeData(
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xff022948),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.amber)),
    fontFamily: 'QuickSand',
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      floatingLabelStyle: TextStyle(color: Colors.amber),
    ),
    scaffoldBackgroundColor: Color(0xff022948),
    //scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.dark(
      //seedColor: Color(0xff010f1b),
      primary: Color(0xff011f38),
      secondary: Colors.amber,
      tertiary: Color(0xff24415c),
    ),
    useMaterial3: true,
  );
}

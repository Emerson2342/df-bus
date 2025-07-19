import 'package:df_bus/controller/storage_controller.dart';
import 'package:df_bus/pages/home_page/widgets/lines_saved_widget.dart';
import 'package:df_bus/pages/home_page/widgets/search_line_input_widget.dart';
import 'package:df_bus/pages/all_bus_location/all_bus_location_page.dart';
import 'package:df_bus/pages/line_details/line_details.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/lines_saved_notifier.dart';
import 'package:df_bus/value_notifiers/show_maps_notifier.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<LinesSavedState> _linesSavedKey = GlobalKey();
  final storageController = getIt<StorageController>();
  final themeNotifier = getIt<ThemeNotifier>();
  final showMapsNotifier = getIt<ShowMapsNotifier>();
  final showLineDetailsNotifier = getIt<ShowLineDetailsMapsNotifier>();
  final linesSavedNotifier = getIt<LinesSavedNotifier>();

  @override
  void initState() {
    super.initState();
    getLinesSaved();
    debugPrint("*******Entrou na Home Page");
  }

  void getLinesSaved() async {
    await storageController.getLines();
    if (linesSavedNotifier.value.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _linesSavedKey.currentState?.getLinesSaved();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (!didPop) {
            final mapsVisible = showMapsNotifier.value;
            final detailsVisible = showLineDetailsNotifier.value;

            if (mapsVisible && detailsVisible) {
              showLineDetailsNotifier.value = false;
            } else if (mapsVisible && !detailsVisible) {
              showMapsNotifier.value = false;
            } else if (!mapsVisible && detailsVisible) {
              showLineDetailsNotifier.value = false;
            } else {
              SystemNavigator.pop();
            }
          }
        },
        child: Stack(
          children: [
            Scaffold(
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 85),
                child: FloatingActionButton(
                  backgroundColor: Colors.black38,
                  onPressed: () {
                    showMapsNotifier.showMaps();
                  },
                  child: Icon(
                    Icons.place_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              appBar: AppBar(
                title: const Text(
                  "DF BUS",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                actions: [
                  ValueListenableBuilder<bool>(
                    valueListenable: themeNotifier,
                    builder: (context, isDarkMode, _) {
                      return IconButton(
                        onPressed: themeNotifier.toggleDarkMode,
                        icon: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: LinesSaved(
                        key: _linesSavedKey,
                      )),
                  // ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.68,
                      child: SearchLineInputWidget()),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: showMapsNotifier,
              builder: (context, show, _) {
                return Offstage(
                  offstage: !show,
                  child: IgnorePointer(
                      ignoring: !show,
                      child: Scaffold(
                        appBar: AppBar(
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(30.0),
                            child: const Text(
                              "Ônibus em tempo real",
                              style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: const Text(
                            "DF BUS",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                          centerTitle: true,
                          leading: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showMapsNotifier.showMaps();
                            },
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        body: BusStopPage(),
                      )),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: showLineDetailsNotifier,
              builder: (context, show, _) {
                return Offstage(
                  offstage: !show,
                  child: IgnorePointer(
                      ignoring: !show, child: LineDetailsWidget()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

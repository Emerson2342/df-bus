import 'package:df_bus/controller/storage_controller.dart';
import 'package:df_bus/pages/home_page/widgets/lines_saved_widget.dart';
import 'package:df_bus/pages/home_page/widgets/search_line_input_widget.dart';
import 'package:df_bus/pages/all_bus_location/all_bus_location_page.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/show_maps_notifier.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import './../../main.dart' show routeObserver;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware
//AutomaticKeepAliveClientMixin
{
  final GlobalKey<LinesSavedState> _linesSavedKey = GlobalKey();
  final storageController = getIt<StorageController>();
  final themeNotifier = getIt<ThemeNotifier>();
  final showMapsNotifier = getIt<ShowMapsNotifier>();
  String linetoSeach = "";
  bool loadingSearch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    debugPrint('****Voltou pra Home Page');
    getLinesSaved();
  }

  @override
  void initState() {
    super.initState();
    getLinesSaved();
    debugPrint("*******Entrou na Home Page");
  }

  void getLinesSaved() async {
    final lines = await storageController.init();
    if (lines.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _linesSavedKey.currentState?.getLinesSaved();
      });
    }
  }

  // @override
  // bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return Stack(
      children: [
        Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: FloatingActionButton(
              backgroundColor: Colors.black38,
              onPressed: () {
                showMapsNotifier.value = !showMapsNotifier.value;
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
                  height: MediaQuery.of(context).size.height * 0.67,
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
                              color: Colors.amber, fontWeight: FontWeight.bold),
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
                          showMapsNotifier.value = false;
                        },
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    body: BusStopPage(),
                  )),
            );
          },
        )
      ],
    );
  }
}

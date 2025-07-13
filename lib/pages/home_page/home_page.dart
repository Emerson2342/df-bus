import 'package:df_bus/controller/storage_controller.dart';
import 'package:df_bus/pages/home_page/widgets/lines_saved_widget.dart';
import 'package:df_bus/pages/home_page/widgets/search_line_input_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import './../../main.dart' show routeObserver;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with RouteAware, AutomaticKeepAliveClientMixin {
  final GlobalKey<LinesSavedState> _linesSavedKey = GlobalKey();
  final storageController = getIt<StorageController>();
  final themeNotifier = getIt<ThemeNotifier>();
  String linetoSeach = "";
  //late List<SearchLine> linesSearched = [];
  bool loadingSearch = false;
  //List<String> linesSaved = [];

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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
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
    );
  }
}

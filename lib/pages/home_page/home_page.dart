import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/home_page/widgets/lines_saved_widget.dart';
import 'package:df_bus/pages/home_page/widgets/search_line_input_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';
import './../../main.dart' show routeObserver;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final GlobalKey<LinesSavedState> _linesSavedKey = GlobalKey();
  final searchLineController = getIt<SearchLineController>();
  String linetoSeach = "";
  late List<SearchLine> linesSearched = [];
  bool loadingSearch = false;
  List<String> linesSaved = [];

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
    final lines = await searchLineController.init();
    if (lines.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _linesSavedKey.currentState?.getLinesSaved();
      });
    }
    linesSaved = lines;
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DF BUS",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.16,
              child: LinesSaved(
                key: _linesSavedKey,
              )),
          // ),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: SearchLineInputWidget()),
        ],
      ),
    );
  }
}

import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/home_page/widgets/lines_result_widget.dart';
import 'package:df_bus/pages/home_page/widgets/lines_saved_widget.dart';
import 'package:df_bus/pages/home_page/widgets/search_line_input_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/widgets/snackbar_message_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchLineController = getIt<SearchLineController>();
  String linetoSeach = "";
  late List<SearchLine> linesSearched = [];
  bool loadingSearch = false;
  List<String> linesSaved = [];
  @override
  void initState() {
    super.initState();
    searchLine();
    getLinesSaved();
  }

  void getLinesSaved() async {
    final lines = await searchLineController.init();
    linesSaved = lines;
    setState(() {});
  }

  void searchLine() async {
    loadingSearch = true;
    final list = await searchLineController.searchLines(linetoSeach);
    linesSearched = list;
    if (list.isEmpty) {
      if (!mounted) return;
      messageSnackbar(context, "Nenhuma linha encontrada");
    }
    setState(() {});
    loadingSearch = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inicial",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SearchLineInputWidget(onAddLine: (line) {
              debugPrint("Buscou a linha $line");
              setState(() {
                linetoSeach = line;
              });
              searchLine();
            }),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              await searchLineController.deleteLines();
            },
            child: Text("Limpar Lista"),
          ),
          SizedBox(height: 16),
          LinesSaved(linesSaved: linesSaved),
          const SizedBox(height: 16),
          if (loadingSearch)
            Expanded(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            LinesResultWidget(linesResult: linesSearched)
        ],
      ),
    );
  }
}

import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/home_page/widgets/lines_result_widget.dart';
import 'package:df_bus/pages/home_page/widgets/search_line_input_widget.dart';
import 'package:df_bus/services/service_locator.dart';
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
  @override
  void initState() {
    super.initState();
    searchLine();
  }

  void searchLine() async {
    final list = await searchLineController.searchLines(linetoSeach);
    setState(() {
      linesSearched = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inicial"),
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
          FutureBuilder(
              future: searchLineController.init(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Erro ao buscar a linha $linetoSeach"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Nenhuma linha encontrada"));
                }
                final linesSaved = snapshot.data!;

                return Expanded(
                    child: ListView.builder(
                        itemCount: linesSaved.length,
                        itemBuilder: (context, index) {
                          final lineSaved = linesSaved[index];
                          return ElevatedButton(
                              onPressed: () {
                                debugPrint("Linha - $lineSaved");
                              },
                              child: Text(lineSaved));
                        }));
              }),
          SizedBox(height: 16),
          LinesResultWidget(linesResult: linesSearched)
        ],
      ),
    );
  }
}

import 'package:animated_toggle/animated_toggle.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/models/search_lines.dart';
import 'package:df_bus/pages/home_page/widgets/lines_result_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';

class SearchLineInputWidget extends StatefulWidget {
  final void Function(String) onAddLine;

  const SearchLineInputWidget({super.key, required this.onAddLine});

  @override
  State<SearchLineInputWidget> createState() => _SearchLineInputWidgetState();
}

class _SearchLineInputWidgetState extends State<SearchLineInputWidget> {
  final searchLineController = getIt<SearchLineController>();
  final TextEditingController _busLineController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  int selectedIndex = 0;
  List<String> options = ['Linha', 'Referência'];
  List<QuerySearch> queryResults = [];
  bool enableFrom = true;
  bool enableTo = true;
  bool loadingSearch = false;
  List<SearchLine> linesSearched = [];

  void _onSubmit() async {
    loadingSearch = true;
    final text = _busLineController.text.trim();
    if (text.isNotEmpty) {
      widget.onAddLine(text);
      _busLineController.clear();
      FocusScope.of(context).unfocus();
    }
    var result =
        await searchLineController.searchLines(_busLineController.text);
    linesSearched = result;
    loadingSearch = false;
    setState(() {});
  }

  void _findByQuery(
      TextEditingController textController, bool isFromText) async {
    final query = textController.text.trim();
    var result = await searchLineController.findByQuery(query);
    if (isFromText) {
      enableFrom = true;
      enableTo = false;
    } else {
      enableFrom = false;
      enableTo = true;
    }
    for (var item in result) {
      item.descricao = item.descricao.split(':').length > 1
          ? item.descricao.split(':')[1]
          : "";
    }
    setState(() {
      queryResults = result;
    });
    debugPrint(
        "***************** tamanho da queryResult ${queryResults.length.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AnimatedHorizontalToggle(
            taps: options,
            width: MediaQuery.of(context).size.width - 100,
            height: 40,
            duration: Duration(milliseconds: 100),
            activeColor: Theme.of(context).colorScheme.secondary,
            initialIndex: 0,
            onChange: (currentIndex, targetIndex) {
              setState(() {
                selectedIndex = currentIndex;
              });
            },
          ),
        ),
        SizedBox(height: 15),
        if (selectedIndex == 0)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _busLineController,
                      decoration: InputDecoration(
                        labelText: 'Digite a linha',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _onSubmit(),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                      size: 35,
                    ),
                    onPressed: _onSubmit,
                  )
                ],
              ),
              const SizedBox(height: 16),
              if (loadingSearch)
                Expanded(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (!loadingSearch && linesSearched.isNotEmpty)
                Expanded(
                  child: LinesResultWidget(linesResult: linesSearched),
                )
            ],
          ),
        if (selectedIndex == 1)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fromController,
                      //enabled: enableFrom,

                      decoration: InputDecoration(
                        labelText: 'Origem',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _findByQuery(_fromController, true),
                      //onSubmitted: (_) => _onSubmit(),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _fromController.text = "";
                        setState(() {
                          queryResults = [];
                          enableFrom = true;
                        });
                      },
                      icon: Icon(Icons.clear))
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      //  enabled: enableTo,
                      controller: _toController,
                      onChanged: (_) => _findByQuery(_toController, false),
                      decoration: InputDecoration(
                        labelText: 'Destino',
                        border: OutlineInputBorder(),
                      ),
                      //onSubmitted: (_) => _onSubmit(),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _toController.text = "";
                        setState(() {
                          queryResults = [];
                          enableTo = true;
                        });
                      },
                      icon: Icon(Icons.clear))
                ],
              ),
              Text("asdfadfasd"),
              SizedBox(
                height: 300,
                child: ListView.builder(
                    itemCount: queryResults.length,
                    itemBuilder: (context, index) {
                      final item = queryResults[index];
                      return Card(
                        child: ListTile(
                          onTap: () {
                            if (enableFrom) {
                              enableFrom = false;
                              _fromController.text = item.descricao;
                            } else {
                              enableTo = false;
                              _toController.text = item.descricao;
                            }
                            setState(() {
                              queryResults = [];
                            });
                          },
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.descricao,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
      ],
    );
  }
}

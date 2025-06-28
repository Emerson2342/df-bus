import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/models/search_lines.dart';
import 'package:df_bus/pages/home_page/widgets/lines_result_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';

class SearchByRefWidget extends StatefulWidget {
  const SearchByRefWidget({super.key});

  @override
  State<SearchByRefWidget> createState() => _SearchByRefWidgetState();
}

class _SearchByRefWidgetState extends State<SearchByRefWidget> {
  final searchLineController = getIt<SearchLineController>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  List<QuerySearch> queryResults = [];
  List<SearchLine> linesResult = [];
  bool loadingSearch = false;
  bool isFetching = false;
  bool isFetchingRef = false;
  bool showLinesResult = false;
  bool showQueryResults = false;
  bool enableFrom = true;
  bool enableTo = true;
  QuerySearch? fromItem;
  QuerySearch? toItem;

  void _findByQuery(
      TextEditingController textController, bool isFromText) async {
    setState(() {
      isFetching = true;
      loadingSearch = true;
      showQueryResults = false;
      showLinesResult = false;
    });
    if (isFromText) {
      enableFrom = true;
      enableTo = false;
    } else {
      enableFrom = false;
      enableTo = true;
    }

    final query = textController.text.trim();
    var result = await searchLineController.findByQuery(query);
    for (var item in result) {
      item.descricao = item.descricao.split(':').length > 1
          ? item.descricao.split(':')[1]
          : "";
    }
    setState(() {
      queryResults = result;
      isFetching = false;
      loadingSearch = false;
      showQueryResults = true;
    });
    debugPrint(
        "***************** tamanho da queryResult ${queryResults.length.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fromController,
                  //enabled: enableFrom,

                  decoration: const InputDecoration(
                    labelText: 'Origem',
                  ),
                  onChanged: (_) => _findByQuery(_fromController, true),
                ),
              ),
              IconButton(
                  onPressed: () {
                    _fromController.text = "";
                    setState(() {
                      queryResults = [];
                      linesResult = [];
                      fromItem = null;
                    });
                  },
                  icon: Icon(Icons.clear))
            ],
          ),
        ),
        //const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _toController,
                  onChanged: (_) => _findByQuery(_toController, false),
                  decoration: const InputDecoration(
                    labelText: 'Destino',
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _toController.text = "";
                  setState(() {
                    queryResults = [];
                    linesResult = [];
                    toItem = null;
                  });
                },
                icon: Icon(Icons.clear),
              )
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          onPressed: fromItem == null || toItem == null
              ? null
              : () async {
                  // debugPrint();
                  setState(() {
                    loadingSearch = true;
                    isFetchingRef = true;
                    showLinesResult = false;
                    showQueryResults = false;
                    linesResult = [];
                  });

                  final list = await searchLineController.searchByRef(
                      fromItem!, toItem!);

                  for (final item in list) {
                    SearchLine s = SearchLine(
                        numero: item.numero,
                        descricao: item.descricao,
                        tarifa: item.faixaTarifaria.tarifa);
                    linesResult.add(s);
                  }
                  setState(() {
                    loadingSearch = false;
                    isFetchingRef = false;
                    showLinesResult = true;
                  });
                },
          child: const Text(
            "Pesquisar",
          ),
        ),
        if (loadingSearch && isFetching)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              semanticsLabel: "Carregando lista...",
            ),
          ),
        if (showQueryResults)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.37,
            child: ListView.builder(
                itemCount: queryResults.length,
                itemBuilder: (context, index) {
                  final item = queryResults[index];
                  return Card(
                    color: Theme.of(context).colorScheme.tertiary,
                    child: ListTile(
                      onTap: () {
                        if (enableFrom) {
                          enableFrom = false;
                          _fromController.text = item.descricao;
                          fromItem = item;
                          FocusScope.of(context).unfocus();
                        } else {
                          enableTo = false;
                          _toController.text = item.descricao;
                          toItem = item;
                          FocusScope.of(context).unfocus();
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
        if (loadingSearch && isFetchingRef)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.37,
            child: const Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            )),
          ),
        if (showLinesResult)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.37,
            child: LinesResultWidget(linesResult: linesResult),
          ),
        AdsBannerWidget()
      ],
    );
  }
}

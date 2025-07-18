import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/models/search_lines.dart';
import 'package:df_bus/pages/home_page/widgets/lines_result_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/widgets/skeleton_lines_result_widget.dart';
import 'package:df_bus/widgets/snackbar_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

  @override
  void initState() {
    super.initState();
  }

  void _findByQuery(
      TextEditingController textController, bool isFromText) async {
    setState(() {
      isFetching = true;
      loadingSearch = true;
      showQueryResults = false;
      showLinesResult = false;
    });

    setState(() {});

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
    if (result.isEmpty) {
      if (!mounted) return;
      messageSnackbar(context, "Nenhum resultado encontrado!");
    }
    debugPrint(
        "***************** tamanho da queryResult ${queryResults.length.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
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
                    if (list.isEmpty) {
                      if (!context.mounted) return;
                      messageSnackbar(context, "Nenhum resultado encontrado!");
                    }
                  },
            child: const Text(
              "Pesquisar",
            ),
          ),
          if (showQueryResults || loadingSearch && isFetching)
            Skeletonizer(
              enabled: loadingSearch && isFetching,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.36,
                child: loadingSearch && isFetching
                    ? ListView.builder(
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Theme.of(context).colorScheme.tertiary,
                            elevation: 5,
                            child: const ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Lorem Ipsum is simply dummy text of the printing",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              trailing: Icon(
                                Icons.check,
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: queryResults.length,
                        itemBuilder: (context, index) {
                          final item = queryResults[index];
                          return Card(
                            color: Theme.of(context).colorScheme.tertiary,
                            elevation: 5,
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
                                      style: TextStyle(
                                          //color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              trailing: Icon(
                                Icons.check,
                                //color: Colors.black,
                              ),
                            ),
                          );
                        }),
              ),
            ),
          if (loadingSearch && isFetchingRef)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.36,
              child: SkeletonLinesResult(),
            ),
          if (showLinesResult)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.36,
              child: LinesResultWidget(linesResult: linesResult),
            ),
          if (!loadingSearch &&
              !isFetching &&
              !showQueryResults &&
              !loadingSearch &&
              !isFetchingRef &&
              !showLinesResult)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.36,
            ),
          AdsBannerWidget()
        ],
      ),
    );
  }
}

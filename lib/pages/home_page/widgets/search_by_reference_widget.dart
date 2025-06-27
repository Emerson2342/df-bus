import 'dart:async';

import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/search_lines.dart';
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
  bool loadingSearch = false;
  bool isFetching = false;
  bool enableFrom = true;
  bool enableTo = true;
  QuerySearch? fromItem;
  QuerySearch? toItem;

  void _findByQuery(
      TextEditingController textController, bool isFromText) async {
    setState(() {
      isFetching = true;
      loadingSearch = true;
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
    });
    debugPrint(
        "***************** tamanho da queryResult ${queryResults.length.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              ),
            ),
            IconButton(
                onPressed: () {
                  _fromController.text = "";
                  setState(() {
                    queryResults = [];
                    fromItem = null;
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
                controller: _toController,
                onChanged: (_) => _findByQuery(_toController, false),
                decoration: InputDecoration(
                  labelText: 'Destino',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _toController.text = "";
                setState(() {
                  queryResults = [];
                  toItem = null;
                });
              },
              icon: Icon(Icons.clear),
            )
          ],
        ),
        ElevatedButton(
          onPressed: () {},
          child: Text(
            "Pesquisar",
          ),
        ),
        if (loadingSearch && isFetching)
          Container(
            color: Colors.amber,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        Container(
          color: Colors.red,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
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
        ),
      ],
    );
  }
}

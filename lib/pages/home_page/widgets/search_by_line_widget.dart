import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/home_page/widgets/lines_result_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/widgets/skeleton_lines_result_widget.dart';
import 'package:df_bus/widgets/snackbar_message_widget.dart';
import 'package:flutter/material.dart';

class SearchByLineWidget extends StatefulWidget {
  const SearchByLineWidget({super.key});

  @override
  State<SearchByLineWidget> createState() => _SearchByLineWidgetState();
}

class _SearchByLineWidgetState extends State<SearchByLineWidget> {
  final TextEditingController _textController = TextEditingController();
  final searchLineController = getIt<SearchLineController>();

  bool loadingSearch = false;
  List<SearchLine> linesSearched = [];
  List<String> linesSaved = [];

  @override
  void initState() {
    _onSubmit();
    super.initState();
  }

  void _onSubmit() async {
    loadingSearch = true;
    final text = _textController.text.trim();
    linesSearched = [];
    if (text.isNotEmpty) {
      _textController.clear();
      FocusScope.of(context).unfocus();
    }

    setState(() {});

    var list = await searchLineController.searchLines(text);

    if (list.isEmpty) {
      if (!mounted) return;
      messageSnackbar(context, "Nenhum resultado encontrado para $text");
      final newList = await searchLineController.searchLines("");
      if (!mounted) return;
      setState(() {
        linesSearched = newList;
        loadingSearch = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        linesSearched = list;
        loadingSearch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        labelText: 'Digite a linha',
                      ),
                      onSubmitted: (_) async => _onSubmit(),
                    ),
                  ),
                ),
                // SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 35,
                  ),
                  onPressed: _onSubmit,
                )
              ],
            ),
          ),
          // SizedBox(height: 7),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.43,
            child: loadingSearch
                ? SkeletonLinesResult()
                : LinesResultWidget(
                    linesResult: linesSearched,
                  ),
          ),
          AdsBannerWidget()
        ],
      ),
    );
  }
}

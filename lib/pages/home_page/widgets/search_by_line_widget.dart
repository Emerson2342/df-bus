import 'package:df_bus/ads/ads_widget.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/home_page/widgets/lines_result_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/widgets/snackbar_message_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchByLineWidget extends StatefulWidget {
  const SearchByLineWidget({super.key});

  @override
  State<SearchByLineWidget> createState() => _SearchByLineWidgetState();
}

class _SearchByLineWidgetState extends State<SearchByLineWidget> {
  final TextEditingController _textController = TextEditingController();
  final searchLineController = getIt<SearchLineController>();
  bool welcomeWidget = true;
  String searchText = "";

  bool loadingSearch = false;
  List<SearchLine> linesSearched = [];
  List<String> linesSaved = [];

  @override
  void initState() {
    super.initState();
  }

  void _onSubmit() async {
    loadingSearch = true;
    List<SearchLine> list = [];
    searchText = _textController.text.trim();
    linesSearched = [];
    _textController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
    try {
      list = await searchLineController.searchLines(searchText);
      if (list.isEmpty) {
        if (!mounted) return;
        messageSnackbar(
            context, "Nenhum resultado encontrado para $searchText");

        setState(() {
          welcomeWidget = true;
          loadingSearch = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          welcomeWidget = false;
          linesSearched = list;
          loadingSearch = false;
        });
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        if (!context.mounted) return;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Ops..."),
                content: Text(
                    "O servidor está fora do ar. Tente novamente mais tarde!"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Fechar"),
                  )
                ],
              );
            });
        return;
      }
    } catch (e) {
      debugPrint("erro ao buscar a linha $searchText - $e");
      return;
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
                        labelText: 'Digite a linha ou cidade',
                      ),
                      //onSubmitted: (_) async => _onSubmit(),
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
          SizedBox(height: 7),
          if (welcomeWidget)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.54,
              child: Text("asdfasdfadf"),
            ),
          if (!welcomeWidget)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.54,
              child: loadingSearch
                  ? CircularProgressIndicator()
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

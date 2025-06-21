import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/widgets/progress_indicator_widget.dart';
import 'package:df_bus/widgets/snackbar_message_widget.dart';
import 'package:flutter/material.dart';

class LineDetailsWidget extends StatefulWidget {
  const LineDetailsWidget({super.key, required this.busLine});

  final String busLine;

  @override
  State<LineDetailsWidget> createState() => _LineDetailsWidgetState();
}

class _LineDetailsWidgetState extends State<LineDetailsWidget> {
  final searchLineController = getIt<SearchLineController>();

  @override
  void initState() {
    super.initState();
    _loadLineDetails();
  }

  void _loadLineDetails() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Linha ${widget.busLine}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: searchLineController.getBusDetails(widget.busLine),
              builder: (context, snapshop) {
                if (snapshop.connectionState == ConnectionState.waiting) {
                  return const ProgressIndicatorWidget();
                } else if (snapshop.hasError) {
                  return Text("Ops...Erro ao buscar a linha ${widget.busLine}");
                }
                final lineDetails = snapshop.data!;
                return Column(
                  children: [
                    Column(
                      children: [Text("")],
                    )
                  ],
                );
              })
        ],
      ),
    );
  }
}

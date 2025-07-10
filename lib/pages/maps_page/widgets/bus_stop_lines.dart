import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/home_page/widgets/lines_result_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/widgets/snackbar_message_widget.dart';
import 'package:flutter/material.dart';

class BusStopLinesBottomSheet extends StatefulWidget {
  const BusStopLinesBottomSheet({super.key, required this.busStopId});

  final String busStopId;

  @override
  State<BusStopLinesBottomSheet> createState() =>
      _BusStopLinesBottomSheetState();
}

class _BusStopLinesBottomSheetState extends State<BusStopLinesBottomSheet> {
  final searchLineController = getIt<SearchLineController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            searchLineController.busService.getBusStopLines(widget.busStopId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary),
                ));
          } else if (snapshot.hasError) {
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              messageSnackbar(context,
                  "Erro ao buscar linhas de ônibus - ${snapshot.error}!");
            });

            return SizedBox.shrink();
          } else if (snapshot.data != null && snapshot.data!.isEmpty) {
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              messageSnackbar(context, "Nenhuma linha encontrada!");
            });
            return SizedBox.shrink();
          } else {
            List<SearchLine> results = [];
            for (final item in snapshot.data!) {
              final line = SearchLine(
                  numero: item.numero,
                  descricao: item.descricao,
                  tarifa: item.faixaTarifaria.tarifa);

              results.add(line);
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LinesResultWidget(linesResult: results),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}

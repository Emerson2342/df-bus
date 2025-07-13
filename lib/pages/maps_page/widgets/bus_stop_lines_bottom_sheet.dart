import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_location.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/home_page/widgets/lines_result_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/widgets/skeleton_lines_result_widget.dart';
import 'package:df_bus/widgets/snackbar_message_widget.dart';
import 'package:flutter/material.dart';

class BusStopLinesBottomSheet extends StatefulWidget {
  const BusStopLinesBottomSheet({super.key, required this.allBuslocation});

  final List<Veiculo> allBuslocation;

  @override
  State<BusStopLinesBottomSheet> createState() =>
      _BusStopLinesBottomSheetState();
}

class _BusStopLinesBottomSheetState extends State<BusStopLinesBottomSheet> {
  final searchLineController = getIt<SearchLineController>();
  final originIdNotifier =
      getIt<ValueNotifier<String>>(instanceName: 'originId');
  final destIdNotifier = getIt<ValueNotifier<String>>(instanceName: 'destId');

  @override
  Widget build(BuildContext context) {
    final Text title = Text(
      "Linhas",
      style: TextStyle(fontWeight: FontWeight.bold),
    );

    final Container line = Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
    );
    return FutureBuilder(
        future: searchLineController.busService
            .getBusStopLines(originIdNotifier.value, destIdNotifier.value),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Column(
                children: [
                  line,
                  title,
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SkeletonLinesResult(),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              messageSnackbar(context,
                  "Erro ao buscar linhas de ônibus. tente novamente mais tarde");
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
            final List<Veiculo> allBus = [];

            for (final item in widget.allBuslocation) {
              final bus = Veiculo(
                  numero: item.numero,
                  linha: item.linha,
                  horario: item.horario,
                  localizacao: item.localizacao,
                  sentido: item.sentido,
                  direcao: item.direcao);
              allBus.add(bus);
            }
            for (final item in snapshot.data!) {
              final isRunning = allBus.any((bus) => bus.linha == item.numero);
              if (isRunning) {
                final line = SearchLine(
                    numero: item.numero,
                    descricao: item.descricao,
                    tarifa: item.faixaTarifaria.tarifa);

                results.add(line);
              }
            }
            originIdNotifier.value = "";
            destIdNotifier.value = "";
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Column(
                children: [
                  line,
                  title,
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

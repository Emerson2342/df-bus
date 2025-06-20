import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';

class LinesResultWidget extends StatefulWidget {
  const LinesResultWidget({super.key, required this.linesResult});

  final List<SearchLine> linesResult;

  @override
  State<LinesResultWidget> createState() => _LinesResultWidgetState();
}

class _LinesResultWidgetState extends State<LinesResultWidget> {
  final searchLineController = getIt<SearchLineController>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(5),
        itemCount: widget.linesResult.length,
        itemBuilder: (context, index) {
          final line = widget.linesResult[index];
          return Card(
            child: ListTile(
              onTap: () async {
                debugPrint('Linha - ${line.numero}');
                //searchLineController.addLine(line.numero);
                //setState(() {});
                searchLineController.addLine(line.numero);
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    line.numero,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        line.descricao,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  Text('R\$ ${line.tarifa.toStringAsFixed(2)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

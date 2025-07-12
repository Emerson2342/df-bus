import 'package:df_bus/controller/storage_controller.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:df_bus/pages/line_details/line_details.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';

class LinesResultWidget extends StatefulWidget {
  const LinesResultWidget({super.key, required this.linesResult});

  final List<SearchLine> linesResult;

  @override
  State<LinesResultWidget> createState() => _LinesResultWidgetState();
}

class _LinesResultWidgetState extends State<LinesResultWidget> {
  final storageController = getIt<StorageController>();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.linesResult.length,
      itemBuilder: (context, index) {
        final line = widget.linesResult[index];
        return Card(
          color: Theme.of(context).colorScheme.tertiary,
          //color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          //   color: Color(0xffffffff),
          elevation: 3,
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 7, right: 7),
            onTap: () async {
              debugPrint('Linha - ${line.numero}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LineDetailsWidget(
                    busLine: line.numero,
                  ),
                ),
              );
              storageController.addLine(line.numero);
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
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      line.descricao,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                Text(
                  'R\$ ${line.tarifa.toStringAsFixed(2)}',
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward),
          ),
        );
      },
    );
  }
}

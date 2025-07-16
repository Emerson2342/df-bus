import 'package:df_bus/helpers/string_formatter.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/line_details_notifier.dart';
import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;
    const textDataColor = Colors.white70;
    const labelStyle = TextStyle(fontWeight: FontWeight.bold, color: textColor);
    final lineDetailsNotifier = getIt<LineDetailsNotifier>();

    return Container(
      padding: const EdgeInsets.all(9),
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          Text(
            lineDetailsNotifier.value[0].descricao,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Empresa: ", style: labelStyle),
              Text(
                lineDetailsNotifier.value[0].operadoras[0].nome,
                style: TextStyle(color: textDataColor),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Tarifa: ",
                style: labelStyle,
              ),
              Text(
                priceBr(lineDetailsNotifier.value[0].faixaTarifaria.tarifa),
                style: TextStyle(color: textDataColor),
              )
            ],
          )
        ],
      ),
    );
  }
}

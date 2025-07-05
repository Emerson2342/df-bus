import 'package:df_bus/helpers/string_formatter.dart';
import 'package:df_bus/models/bus_model.dart';
import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key, required this.lineDetails});

  final DetalheOnibus lineDetails;

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;
    const textDataColor = Colors.white70;
    const labelStyle = TextStyle(fontWeight: FontWeight.bold, color: textColor);

    return Container(
      padding: const EdgeInsets.all(9),
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          Text(
            lineDetails.descricao,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Empresa: ", style: labelStyle),
              Text(
                lineDetails.operadoras[0].nome,
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
                priceBr(lineDetails.faixaTarifaria.tarifa),
                style: TextStyle(color: textDataColor),
              )
            ],
          )
        ],
      ),
    );
  }
}

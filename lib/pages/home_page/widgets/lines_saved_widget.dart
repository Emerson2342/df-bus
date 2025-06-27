import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/pages/line_details/line_details.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';

class LinesSaved extends StatelessWidget {
  const LinesSaved({
    super.key,
    required this.linesSaved,
  });

  final List<String> linesSaved;

  @override
  Widget build(BuildContext context) {
    final searchLineController = getIt<SearchLineController>();
    return Column(
      children: [
        const SizedBox(height: 7),
        Text(
          "Últimas Buscas",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Wrap(spacing: 3, runSpacing: 3, children: [
          ...linesSaved.map((lineSaved) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 8 * 3) / 4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LineDetailsWidget(busLine: lineSaved),
                    ),
                  );
                  await searchLineController.addLine(lineSaved);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      lineSaved,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ]),
      ],
    );
  }
}

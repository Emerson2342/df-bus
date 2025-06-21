import 'package:df_bus/pages/line_details/line_details.dart';
import 'package:flutter/material.dart';

class LinesSaved extends StatelessWidget {
  const LinesSaved({
    super.key,
    required this.linesSaved,
  });

  final List<String> linesSaved;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: linesSaved.map((lineSaved) {
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
                  builder: (context) => LineDetailsWidget(busLine: lineSaved),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_bus,
                  color: Colors.white,
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
    );
  }
}

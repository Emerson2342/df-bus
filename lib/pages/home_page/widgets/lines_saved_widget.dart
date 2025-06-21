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
      spacing: 8,
      runSpacing: 8,
      children: linesSaved.map((lineSaved) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary),
          onPressed: () => debugPrint('Linha - $lineSaved'),
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
        );
      }).toList(),
    );
  }
}

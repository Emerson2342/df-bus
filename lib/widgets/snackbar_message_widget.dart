import 'package:flutter/material.dart';

void messageSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      content: Text(
        message,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      duration: Duration(seconds: 5),
    ),
  );
}

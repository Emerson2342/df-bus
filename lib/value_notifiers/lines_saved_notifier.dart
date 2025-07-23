import 'package:flutter/material.dart';

class LinesSavedNotifier extends ValueNotifier<List<String>> {
  LinesSavedNotifier() : super([]);

  void setLinesSaved(List<String> newList) {
    value = newList;
  }
}

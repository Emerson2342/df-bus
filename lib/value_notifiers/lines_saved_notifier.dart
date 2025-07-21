import 'package:flutter/material.dart';

class LinesSavedNotifier extends ValueNotifier<List<String>> {
  LinesSavedNotifier() : super([]);

  List<String> get linesSaved => value;

  void setLinesSaved(List<String> newList) {
    value = newList;
  }
}

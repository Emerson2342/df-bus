import 'package:flutter/material.dart';

class ShowMapsNotifier extends ValueNotifier<bool> {
  ShowMapsNotifier() : super(false);

  bool get showMapsScreen => value;

  void showMaps() {
    value = !value;
  }
}

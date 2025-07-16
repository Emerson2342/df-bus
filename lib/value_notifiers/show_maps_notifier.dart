import 'package:flutter/material.dart';

class ShowMapsNotifier extends ValueNotifier<bool> {
  ShowMapsNotifier() : super(false);

  bool get showMapsScreen => value;

  void showMaps() {
    value = !value;
  }
}

class ShowLineDetailsMapsNotifier extends ValueNotifier<bool> {
  ShowLineDetailsMapsNotifier() : super(false);

  bool get showLinesDetailsMaps => value;

  void setShowLineDetails(bool showLineDetails) {
    value = showLineDetails;
  }
}

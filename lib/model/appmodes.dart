import 'package:flutter/cupertino.dart';

enum Modes { defaultMode, pointMode, selectionMode }

class AppModes with ChangeNotifier {
  Modes selectedMode = Modes.selectionMode;

  String getModeName(var selectedMode) {
    switch (selectedMode) {
      case Modes.pointMode:
        return 'Edge Mode';
      case Modes.selectionMode:
        return 'Selection Mode';
      case Modes.defaultMode:
        return 'Default Mode';
      default:
        return '';
    }
  }

  void setSelectedMode(Modes mode) {
    switch (mode) {
      case Modes.defaultMode:
        this.selectedMode = Modes.defaultMode;
        notifyListeners();
        break;
      case Modes.pointMode:
        this.selectedMode = Modes.pointMode;
        notifyListeners();
        break;
      case Modes.selectionMode:
        this.selectedMode = Modes.selectionMode;
        notifyListeners();
        break;
    }

  }
}

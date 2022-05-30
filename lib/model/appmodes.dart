import 'package:flutter/cupertino.dart';

enum Mode { defaultMode, pointMode, selectionMode, editSegmentMode}

class AppModes with ChangeNotifier {
  Mode selectedMode = Mode.selectionMode;

  String getModeName(var selectedMode) {
    switch (selectedMode) {
      case Mode.pointMode:
        return 'Edge Mode';
      case Mode.selectionMode:
        return 'Selection Mode';
      case Mode.defaultMode:
        return 'Default Mode';
      case Mode.editSegmentMode:
        return 'Edit Segment Mode';
      default:
        return '';
    }
  }

  void setSelectedMode(Mode mode) {
    switch (mode) {
      case Mode.defaultMode:
        this.selectedMode = Mode.defaultMode;
        notifyListeners();
        break;
      case Mode.pointMode:
        this.selectedMode = Mode.pointMode;
        notifyListeners();
        break;
      case Mode.selectionMode:
        this.selectedMode = Mode.selectionMode;
        notifyListeners();
        break;
      case Mode.editSegmentMode:
        this.selectedMode = Mode.selectionMode;
        break;
    }

  }
}

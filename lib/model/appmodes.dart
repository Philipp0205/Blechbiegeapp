enum Modes { defaultMode, pointMode, selectionMode }

class AppModes {
  String getModeName(var selectedMode) {
    switch (selectedMode) {
      case Modes.pointMode:
        return 'Edge Mode';
      case Modes.selectionMode:
        return 'Selection Mode';
      case Modes.defaultMode:
        return '';
      default:
        return '';
    }
  }
}

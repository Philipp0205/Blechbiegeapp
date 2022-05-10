enum Modes { defaultMode, edgeMode, selectionMode }

class AppModes {
  String getModeName(var selectedMode) {
    switch (selectedMode) {
      case Modes.edgeMode:
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

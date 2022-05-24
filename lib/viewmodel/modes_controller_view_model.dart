import 'package:flutter/cupertino.dart';

import '../model/appmodes.dart';
import '../model/segment.dart';

class ModesViewModel extends ChangeNotifier {

  // CurrentPathViewModel _currentPathViewModel = getIt<CurrentPathViewModel>();

  Modes selectedMode = Modes.defaultMode;

  void toggleSelectionMode() {
    print('toggleselectionmode');
    selectedMode = Modes.selectionMode;
    notifyListeners();
  }

  void toggleEdgeMode() {
    selectedMode = Modes.pointMode;
    notifyListeners();
  }

  void toggleDefaultMode() {
    print('toggle default mode');
    selectedMode = Modes.defaultMode;
    // _currentPathViewModel.unselectCurrentLine();
    notifyListeners();
  }

  void clear() {
    selectedMode = Modes.defaultMode;
  }

  void setSelectedMode(Modes mode) {
    this.selectedMode = mode;
    notifyListeners();
  }
}

import 'package:flutter/cupertino.dart';

import '../model/appmodes.dart';
import '../model/segment_model.dart';

class ModesViewModel extends ChangeNotifier {

  // CurrentPathViewModel _currentPathViewModel = getIt<CurrentPathViewModel>();

  Mode selectedMode = Mode.defaultMode;

  void toggleSelectionMode() {
    print('toggleselectionmode');
    selectedMode = Mode.selectionMode;
    notifyListeners();
  }

  void toggleEdgeMode() {
    selectedMode = Mode.pointMode;
    notifyListeners();
  }

  void toggleDefaultMode() {
    print('toggle default mode');
    selectedMode = Mode.defaultMode;
    // _currentPathViewModel.unselectCurrentLine();
    notifyListeners();
  }

  void clear() {
    selectedMode = Mode.defaultMode;
  }

  void setSelectedMode(Mode mode) {
    this.selectedMode = mode;
    notifyListeners();
  }
}

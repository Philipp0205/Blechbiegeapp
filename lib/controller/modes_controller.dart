import 'package:flutter/cupertino.dart';

import '../model/appmodes.dart';

class ModesController extends ChangeNotifier {
  Modes selectedMode = Modes.defaultMode;

  void toggleSelectionMode() {
    selectedMode = Modes.selectionMode;
    // clearSegmentSelection(selectedSegment);
    notifyListeners();
  }

  void toggleEdgeMode() {
    selectedMode = Modes.pointMode;
    notifyListeners();
  }

  void toggleDefaultMode() {
    Offset offset = new Offset(0, 0);
    // selectedSegment.selectedEdge = offset;
    // selectedSegment.isSelected = false;
    selectedMode = Modes.defaultMode;
    notifyListeners();
  }

  void clear() {
    selectedMode = Modes.defaultMode;
  }
}

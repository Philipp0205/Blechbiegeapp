part of 'constructing_page_bloc.dart';

abstract class ConstructingPageEvent {
  const ConstructingPageEvent();
}

class ConstructingPageCreated extends ConstructingPageEvent {
  final List<Segment> segment;

  const ConstructingPageCreated({required this.segment});
}

// section Segment details
/*
*   ____                                  _          _      _        _ _
*  / ___|  ___  __ _ _ __ ___   ___ _ __ | |_     __| | ___| |_ __ _(_) |___
*  \___ \ / _ \/ _` | '_ ` _ \ / _ \ '_ \| __|   / _` |/ _ \ __/ _` | | / __|
*   ___) |  __/ (_| | | | | | |  __/ | | | |_   | (_| |  __/ || (_| | | \__ \
*  |____/ \___|\__, |_| |_| |_|\___|_| |_|\__|   \__,_|\___|\__\__,_|_|_|___/
*              |___/
*/

class ConstructingPageCheckboxChanged extends ConstructingPageEvent {
  final bool checkBoxValue;
  final CheckBoxEnum checkBox;

  const ConstructingPageCheckboxChanged(
      {required this.checkBox, required this.checkBoxValue});
}

class ConstructingPageCoordinatesShown extends ConstructingPageEvent {
  final bool showCoordinates;
  const ConstructingPageCoordinatesShown({required this.showCoordinates});
}

class ConstructingPageEdgeLengthsShown extends ConstructingPageEvent {
  final bool showEdgeLengths;
  const ConstructingPageEdgeLengthsShown({required this.showEdgeLengths});
}

class ConstructingPageAnglesShown extends ConstructingPageEvent {
  final bool showAngles;
  const ConstructingPageAnglesShown({required this.showAngles});
}

class ConstructingPageSChanged extends ConstructingPageEvent {
  final double s;
  const ConstructingPageSChanged({required this.s});
}


// section Debugging
/*
*   ____       _                       _
*  |  _ \  ___| |__  _   _  __ _  __ _(_)_ __   __ _
*  | | | |/ _ \ '_ \| | | |/ _` |/ _` | | '_ \ / _` |
*  | |_| |  __/ |_) | |_| | (_| | (_| | | | | | (_| |
*  |____/ \___|_.__/ \__,_|\__, |\__, |_|_| |_|\__, |
*                          |___/ |___/         |___/
*/
class ConstructingPageColorChanged extends ConstructingPageEvent {
  final Color color;
  const ConstructingPageColorChanged({required this.color});
}

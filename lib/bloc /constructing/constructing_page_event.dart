part of 'constructing_page_bloc.dart';

abstract class ConstructingPageEvent {
  const ConstructingPageEvent();
}

class ConstructingPageCreated extends ConstructingPageEvent {
  final List<Segment> segment;

  const ConstructingPageCreated({required this.segment});
}

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

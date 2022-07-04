part of 'configuration_page_bloc.dart';

abstract class ConfigurationPageEvent {
  const ConfigurationPageEvent();
}

class ConfigPageCreated extends ConfigurationPageEvent {
  final List<Line2> lines;

  const ConfigPageCreated({required this.lines});
}

class ConfigCheckboxChanged extends ConfigurationPageEvent {
  final bool checkBoxValue;
  final CheckBoxEnum checkBox;

  const ConfigCheckboxChanged(
      {required this.checkBox, required this.checkBoxValue});
}

class ConfigCoordinatesShown extends ConfigurationPageEvent {
  final bool showCoordinates;
  const ConfigCoordinatesShown({required this.showCoordinates});
}

class ConfigEdgeLengthsShown extends ConfigurationPageEvent {
  final bool showEdgeLengths;
  const ConfigEdgeLengthsShown({required this.showEdgeLengths});
}

class ConfigAnglesShown extends ConfigurationPageEvent {
  final bool showAngles;
  const ConfigAnglesShown({required this.showAngles});
}

class ConfigSChanged extends ConfigurationPageEvent {
  final double s;
  const ConfigSChanged({required this.s});
}

class ConfigRChanged extends ConfigurationPageEvent {
  final double r;
  const ConfigRChanged({required this.r});
}

class ConfigShapeAdded extends ConfigurationPageEvent {
  final Shape shape;
  const ConfigShapeAdded({required this.shape});
}



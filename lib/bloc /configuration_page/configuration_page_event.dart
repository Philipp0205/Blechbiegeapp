part of 'configuration_page_bloc.dart';

abstract class ConfigurationPageEvent {
  const ConfigurationPageEvent();
}

class ConfigPageCreated extends ConfigurationPageEvent {
  final List<Line> lines;
  final List<Tool> tools;

  const ConfigPageCreated({required this.lines, required this.tools});
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
  final Tool shape;

  const ConfigShapeAdded({required this.shape});
}

/// Event that triggers when the [markAdapterLineMode] is true.
class ConfigToggleMarkAdapterLineMode extends ConfigurationPageEvent {
  final bool adapterLineMode;

  const ConfigToggleMarkAdapterLineMode({required this.adapterLineMode});
}

/// Event that is triggered when the user tabs on a line when the
/// [markAdapterLineMode] is true.
class ConfigMarkAdapterLine extends ConfigurationPageEvent {
  final Offset offset;

  const ConfigMarkAdapterLine({required this.offset});
}

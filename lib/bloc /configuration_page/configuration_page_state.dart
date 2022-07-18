part of 'configuration_page_bloc.dart';

class ConfigPageState extends Equatable {
  final List<Segment> segment;
  final List<Tool> tools;
  final List<Line> lines;
  final List<ToolType2> toolTypes;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final bool markAdapterLineMode;
  final double s;
  final double r;

  const ConfigPageState(
      {required this.segment,
      required this.lines,
      required this.tools,
      required this.toolTypes,
      required this.showEdgeLengths,
      required this.showCoordinates,
      required this.showAngles,
      required this.markAdapterLineMode,
      required this.s,
      required this.r});

  @override
  List<Object?> get props => [
        lines,
        segment,
        showCoordinates,
        showEdgeLengths,
        showAngles,
        s,
        r,
        markAdapterLineMode,
        tools,
        toolTypes
      ];

  ConfigPageState copyWith({
    List<Segment>? segment,
    List<Tool>? tools,
    List<Line>? lines,
    List<ToolType2>? toolTypes,
    bool? showCoordinates,
    bool? showEdgeLengths,
    bool? showAngles,
    bool? markAdapterLineMode,
    double? s,
    double? r,
  }) {
    return ConfigPageState(
      segment: segment ?? this.segment,
      tools: tools ?? this.tools,
      lines: lines ?? this.lines,
      toolTypes: toolTypes ?? this.toolTypes,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      showEdgeLengths: showEdgeLengths ?? this.showEdgeLengths,
      showAngles: showAngles ?? this.showAngles,
      markAdapterLineMode: markAdapterLineMode ?? this.markAdapterLineMode,
      s: s ?? this.s,
      r: r ?? this.r,
    );
  }
}

class ConstructingPageInitial extends ConfigPageState {
  final List<Segment> segment;
  final List<Tool> tools;
  final List<Line> lines;
  final List<ToolType2> toolTypes;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool markAdapterLineMode;
  final bool showAngles;
  final double s;
  final double r;

  const ConstructingPageInitial({
    required this.segment,
    required this.lines,
    required this.tools,
    required this.toolTypes,
    required this.showCoordinates,
    required this.showEdgeLengths,
    required this.markAdapterLineMode,
    required this.showAngles,
    required this.s,
    required this.r,
  }) : super(
            segment: segment,
            toolTypes: toolTypes,
            lines: lines,
            showEdgeLengths: showEdgeLengths,
            tools: tools,
            showCoordinates: showCoordinates,
            showAngles: showAngles,
            markAdapterLineMode: markAdapterLineMode,
            s: s,
            r: r);
}

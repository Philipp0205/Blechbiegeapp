part of 'configuration_page_bloc.dart';

class ConfigPageState extends Equatable {
  final List<Segment> segment;
  final List<Line> lines;
  final List<Tool> shapes;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final double s;
  final double r;

  const ConfigPageState(
      {required this.segment,
      required this.lines,
      required this.shapes,
      required this.showEdgeLengths,
      required this.showCoordinates,
      required this.showAngles,
      required this.s,
      required this.r});

  @override
  List<Object?> get props =>
      [lines, segment, showCoordinates, showEdgeLengths, showAngles, s, r, shapes];

  ConfigPageState copyWith({
    List<Segment>? segment,
    List<Line>? lines,
    List<Tool>? shapes,
    bool? showCoordinates,
    bool? showEdgeLengths,
    bool? showAngles,
    double? s,
    double? r,
  }) {
    return ConfigPageState(
      segment: segment ?? this.segment,
      lines: lines ?? this.lines,
      shapes: shapes ?? this.shapes,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      showEdgeLengths: showEdgeLengths ?? this.showEdgeLengths,
      showAngles: showAngles ?? this.showAngles,
      s: s ?? this.s,
      r: r ?? this.r,
    );
  }
}

class ConstructingPageInitial extends ConfigPageState {
  final List<Segment> segment;
  final List<Line> lines;
  final List<Tool> shapes;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final double s;
  final double r;

  const ConstructingPageInitial({
    required this.segment,
    required this.lines,
    required this.shapes,
    required this.showCoordinates,
    required this.showEdgeLengths,
    required this.showAngles,
    required this.s,
    required this.r,
  }) : super(
            segment: segment,
            lines: lines,
            shapes: shapes,
            showEdgeLengths: showEdgeLengths,
            showCoordinates: showCoordinates,
            showAngles: showAngles,
            s: s,
            r: r);
}

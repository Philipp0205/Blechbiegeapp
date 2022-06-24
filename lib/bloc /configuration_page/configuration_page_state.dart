part of 'configuration_page_bloc.dart';

class ConfigPageState extends Equatable {
  final List<Segment> segment;
  final List<Shape> shapes;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final double s;
  final double r;

  const ConfigPageState(
      {required this.segment,
      required this.shapes,
      required this.showEdgeLengths,
      required this.showCoordinates,
      required this.showAngles,
      required this.s,
      required this.r});

  ConfigPageState copyWith(
      {List<Segment>? segment,
      List<Shape>? shapes,
      bool? showCoordinates,
      bool? showEdgeLengths,
      bool? showAngles,
      Color? color,
      double? s,
      double? r}) {
    return ConfigPageState(
      shapes: shapes ?? this.shapes,
      segment: segment ?? this.segment,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      showEdgeLengths: showEdgeLengths ?? this.showEdgeLengths,
      showAngles: showAngles ?? this.showAngles,
      s: s ?? this.s,
      r: r ?? this.r,
    );
  }

  @override
  List<Object?> get props =>
      [segment, showCoordinates, showEdgeLengths, showAngles, s, r];
}

class ConstructingPageInitial extends ConfigPageState {
  final List<Segment> segment;
  final List<Shape> shapes;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final double s;
  final double r;

  const ConstructingPageInitial({
    required this.segment,
    required this.shapes,
    required this.showCoordinates,
    required this.showEdgeLengths,
    required this.showAngles,
    required this.s,
    required this.r,
  }) : super(
            segment: segment,
            shapes: shapes,
            showEdgeLengths: showEdgeLengths,
            showCoordinates: showCoordinates,
            showAngles: showAngles,
            s: s,
            r: r);
}

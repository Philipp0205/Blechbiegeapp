part of 'constructing_page_bloc.dart';

class ConstructingPageState extends Equatable {
  final List<Segment> segment;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final double s;
  final double radius;

  //debugging
  final Color color;

  const ConstructingPageState(
      {required this.segment,
      required this.showEdgeLengths,
      required this.showCoordinates,
      required this.showAngles,
      required this.color,
      required this.s,
      required this.radius});

  ConstructingPageState copyWith(
      {List<Segment>? segment,
      bool? showCoordinates,
      bool? showEdgeLengths,
      bool? showAngles,
      Color? color,
      double? s,
      double? radius}) {
    return ConstructingPageState(
      segment: segment ?? this.segment,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      showEdgeLengths: showEdgeLengths ?? this.showEdgeLengths,
      showAngles: showAngles ?? this.showAngles,
      color: color ?? this.color,
      s: s ?? this.s,
      radius: radius ?? this.radius,
    );
  }

  @override
  List<Object?> get props =>
      [segment, showCoordinates, showEdgeLengths, showAngles, color, s];
}

class ConstructingPageInitial extends ConstructingPageState {
  final List<Segment> segment;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final Color color;
  final double s;
  final double radius;

  const ConstructingPageInitial({
    required this.segment,
    required this.showCoordinates,
    required this.showEdgeLengths,
    required this.showAngles,
    required this.color,
    required this.s,
    required this.radius,
  }) : super(
            segment: segment,
            showEdgeLengths: showEdgeLengths,
            showCoordinates: showCoordinates,
            showAngles: showAngles,
            color: color,
            s: s,
            radius: radius);
}

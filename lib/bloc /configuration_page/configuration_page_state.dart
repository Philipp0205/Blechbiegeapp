part of 'configuration_page_bloc.dart';

class ConstructingPageState extends Equatable {
  final List<Segment> segment;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final double s;
  final double r;

  const ConstructingPageState(
      {required this.segment,
      required this.showEdgeLengths,
      required this.showCoordinates,
      required this.showAngles,
      required this.s,
      required this.r});

  ConstructingPageState copyWith(
      {List<Segment>? segment,
      bool? showCoordinates,
      bool? showEdgeLengths,
      bool? showAngles,
      Color? color,
      double? s,
      double? r}) {
    return ConstructingPageState(
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

class ConstructingPageInitial extends ConstructingPageState {
  final List<Segment> segment;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final double s;
  final double r;

  const ConstructingPageInitial({
    required this.segment,
    required this.showCoordinates,
    required this.showEdgeLengths,
    required this.showAngles,
    required this.s,
    required this.r,
  }) : super(
            segment: segment,
            showEdgeLengths: showEdgeLengths,
            showCoordinates: showCoordinates,
            showAngles: showAngles,
            s: s,
            r: r);
}

part of 'constructing_page_bloc.dart';

class ConstructingPageState extends Equatable {
  final List<Segment> segment;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;

  //debugging
  final Color color;

  const ConstructingPageState({
    required this.segment,
    required this.showEdgeLengths,
    required this.showCoordinates,
    required this.showAngles,
    required this.color,
  });

  ConstructingPageState copyWith({
    List<Segment>? segment,
    bool? showCoordinates,
    bool? showEdgeLengths,
    bool? showAngles,
    Color? color,
  }) {
    return ConstructingPageState(
      segment: segment ?? this.segment,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      showEdgeLengths: showEdgeLengths ?? this.showEdgeLengths,
      showAngles: showAngles ?? this.showAngles,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props =>
      [segment, showCoordinates, showEdgeLengths, showAngles, color];
}

class ConstructingPageInitial extends ConstructingPageState {
  final List<Segment> segment;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;
  final Color color;

  const ConstructingPageInitial(
      {required this.segment,
      required this.showCoordinates,
      required this.showEdgeLengths,
      required this.showAngles,
      required this.color})
      : super(
            segment: segment,
            showEdgeLengths: showEdgeLengths,
            showCoordinates: showCoordinates,
            showAngles: showAngles,
            color: color);
}

// class ConstructingPageCreate extends ConstructingPageState {
//   final List<Segment2> segment;
//
//   const ConstructingPageCreate({required this.segment})
//       : super(segment: segment);
// }
//
// class ConstructingPageToggleCoordinates extends ConstructingPageState {
//   final bool areShown;
//
//   const ConstructingPageToggleCoordinates({required this.areShown}) :
//         super()
// }

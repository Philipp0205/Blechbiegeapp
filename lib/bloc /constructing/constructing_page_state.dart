part of 'constructing_page_bloc.dart';

class ConstructingPageState extends Equatable {
  final List<Segment2> segment;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;

  const ConstructingPageState(
      {required this.segment,
      required this.showEdgeLengths,
      required this.showCoordinates,
      required this.showAngles});

  ConstructingPageState copyWith({
    List<Segment2>? segment,
    bool? showCoordinates,
    bool? showEdgeLengths,
    bool? showAngles,
  }) {
    return ConstructingPageState(
      segment: segment ?? this.segment,
      showCoordinates: showCoordinates ?? this.showCoordinates,
      showEdgeLengths: showEdgeLengths ?? this.showEdgeLengths,
      showAngles: showAngles ?? this.showAngles,
    );
  }

  @override
  List<Object?> get props => [segment, showCoordinates, showEdgeLengths, showAngles];
}

class ConstructingPageInitial extends ConstructingPageState {
  final List<Segment2> segment;
  final bool showCoordinates;
  final bool showEdgeLengths;
  final bool showAngles;

  const ConstructingPageInitial(
      {required this.segment,
      required this.showCoordinates,
      required this.showEdgeLengths,
      required this.showAngles})
      : super(
            segment: segment,
            showEdgeLengths: showEdgeLengths,
            showCoordinates: showCoordinates,
            showAngles: showAngles);
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

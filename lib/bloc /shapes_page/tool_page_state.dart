part of 'tool_page_bloc.dart';

/// State of the [ToolPageBloc].
/// Contains lists for all [Tool]s [beams], all upper beams ('Oberwangen') [upperBeams],
/// all lower beams ('Unterwangen') [lowerBeams],
/// and all bending beams ('Biegewangen') [bendingBeams].
class ToolPageState extends Equatable {
  final List<Tool> beams;
  final List<Tool> tracks;
  final bool isSelectionMode;

  const ToolPageState({
    required this.beams,
    required this.tracks,
    required this.isSelectionMode,
  });

  /// Copy the state with the given parameters.
  /// Parameters are nullable.

  @override
  List<Object> get props => [beams, tracks, isSelectionMode];

  ToolPageState copyWith({
    List<Tool>? beams,
    List<Tool>? tracks,
    bool? isSelectionMode,
  }) {
    return ToolPageState(
      beams: beams ?? this.beams,
      tracks: tracks ?? this.tracks,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }
}

/// Class & constructor for the initial state of the [ToolPageBloc].
class ShapesPageInitial extends ToolPageState {
  final List<Tool> beams;
  final List<Tool> tracks;
  final Map<Tool, bool> selectedTools;
  final bool isSelectionMode;

  ShapesPageInitial(
      {required this.beams,
      required this.tracks,
      required this.isSelectionMode,
      required this.selectedTools})
      : super(beams: beams, tracks: tracks, isSelectionMode: isSelectionMode);
}

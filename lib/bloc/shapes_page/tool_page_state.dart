part of 'tool_page_bloc.dart';

/// State of the [ToolPageBloc].
/// Contains lists for all [Tool]s [beams], all upper beams ('Oberwangen') [upperBeams],
/// all lower beams ('Unterwangen') [lowerBeams],
/// and all bending beams ('Biegewangen') [bendingBeams].
class ToolPageState extends Equatable {
  final List<Tool> tools;
  final bool isSelectionMode;

  const ToolPageState({
    required this.tools,
    required this.isSelectionMode,
  });

  /// Copy the state with the given parameters.
  /// Parameters are nullable.

  @override
  List<Object> get props => [tools, isSelectionMode];

  ToolPageState copyWith({
    List<Tool>? tools,
    bool? isSelectionMode,
  }) {
    return ToolPageState(
      tools: tools ?? this.tools,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }
}

/// Class & constructor for the initial state of the [ToolPageBloc].
class ShapesPageInitial extends ToolPageState {
  final List<Tool> tools;
  final Map<Tool, bool> selectedTools;
  final bool isSelectionMode;

  ShapesPageInitial(
      {required this.tools,
      required this.isSelectionMode,
      required this.selectedTools})
      : super(tools: tools, isSelectionMode: isSelectionMode);
}

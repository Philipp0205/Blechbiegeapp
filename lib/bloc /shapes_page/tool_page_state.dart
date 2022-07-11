part of 'tool_page_bloc.dart';

/// State of the [ToolPageBloc].
/// Contains lists for all [Tool]s [tools], all upper beams ('Oberwangen') [upperBeams],
/// all lower beams ('Unterwangen') [lowerBeams],
/// and all bending beams ('Biegewangen') [bendingBeams].
class ToolPageState extends Equatable {
  final List<Tool> tools;
  final Map<Tool, bool> selectedTools;
  final bool isSelectionMode;

  const ToolPageState(
      {required this.tools,
      required this.isSelectionMode,
      required this.selectedTools});



  /// Copy the state with the given parameters.
  /// Parameters are nullable.
  ToolPageState copyWith({
    List<Tool>? tools,
    final Map<Tool, bool>? selectedTools,
    bool? isSelectionMode,
  }) {
    return ToolPageState(
      tools: tools ?? this.tools,
      selectedTools: selectedTools ?? this.selectedTools,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  @override
  List<Object> get props => [tools, isSelectionMode, selectedTools];
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
      : super(
            tools: tools,
            isSelectionMode: isSelectionMode,
            selectedTools: selectedTools);
}

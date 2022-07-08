part of 'tool_page_bloc.dart';

class ToolPageState extends Equatable {
  final List<Tool> tools;

  const ToolPageState({required this.tools});

  @override
  List<Object> get props => [tools];

  ToolPageState copyWith({
    List<Tool>? shapes,
  }) {
    return ToolPageState(
      tools: shapes ?? this.tools,
    );
  }
}

class ShapesPageInitial extends ToolPageState {
  ShapesPageInitial({required List<Tool> shapes}) : super(tools: shapes);
}

class ShapesChangeSuccess extends ToolPageState {
  final List<Tool> tools;
  const ShapesChangeSuccess({required this.tools}) : super(tools: tools);
}

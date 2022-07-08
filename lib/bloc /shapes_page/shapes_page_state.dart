part of 'shapes_page_bloc.dart';

class ShapesPageState extends Equatable {
  final List<Tool> shapes;

  const ShapesPageState({required this.shapes});

  @override
  List<Object> get props => [shapes];

  ShapesPageState copyWith({
    List<Tool>? shapes,
  }) {
    return ShapesPageState(
      shapes: shapes ?? this.shapes,
    );
  }
}

class ShapesPageInitial extends ShapesPageState {
  ShapesPageInitial({required List<Tool> shapes}) : super(shapes: shapes);
}

class ShapesChangeSuccess extends ShapesPageState {
  final List<Tool> shapes;
  const ShapesChangeSuccess({required this.shapes}) : super(shapes: shapes);
}

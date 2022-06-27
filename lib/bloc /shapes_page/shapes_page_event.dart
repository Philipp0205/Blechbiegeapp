part of 'shapes_page_bloc.dart';

abstract class ShapesPageEvent extends Equatable {
  const ShapesPageEvent();

  @override
  List<Object> get props => [];
}

class ShapeAdded extends ShapesPageEvent {
  final Shape shape;
  ShapeAdded({required this.shape});
}

class ShapeDeleted extends ShapesPageEvent {
  final Shape shape;
  ShapeDeleted({required this.shape});
}
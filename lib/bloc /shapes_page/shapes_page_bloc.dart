import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/simulation/shape.dart';

part 'shapes_page_event.dart';

part 'shapes_page_state.dart';

class ShapesPageBloc extends Bloc<ShapesPageEvent, ShapesPageState> {
  ShapesPageBloc() : super(ShapesPageInitial(shapes: [])) {
    on<ShapeAdded>(_addShape);
    on<ShapeDeleted>(_deleteShape);
  }

  void _addShape(ShapeAdded event, Emitter<ShapesPageState> emit) {
    List<Shape> shapes = state.shapes;
    shapes.add(event.shape);
    emit(ShapesChangeSuccess(shapes: shapes));
  }

  void _deleteShape(ShapeDeleted event, Emitter<ShapesPageState> emit) {
    print('delete shape');
    List<Shape> shapes = state.shapes;
    shapes.remove(event.shape);
    emit(ShapesChangeSuccess(shapes: shapes));
  }
}

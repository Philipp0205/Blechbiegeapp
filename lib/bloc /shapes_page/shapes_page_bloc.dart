import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../model/simulation/shape.dart';
import '../../persistence/database_service.dart';

part 'shapes_page_event.dart';

part 'shapes_page_state.dart';

class ShapesPageBloc extends Bloc<ShapesPageEvent, ShapesPageState> {
  DatabaseService _service = new DatabaseService();
  late Box box = Hive.box('shapes');

  ShapesPageBloc() : super(ShapesPageInitial(shapes: [])) {
    on<ShapesPageCreated>(_shapesPageCreated);
    on<ShapeAdded>(_addShape);
    on<ShapeDeleted>(_deleteShape);
    on<ShapeEdited>(_editShape);
    on<ShapesSavedToDisk>(_saveShapesToDisk);
  }

  Future<void> _addShape(
      ShapeAdded event, Emitter<ShapesPageState> emit) async {
    print('add shape shapes page bloc');
    List<Shape> shapes = state.shapes;
    shapes.add(event.shape);

    Box box = await _service.createBox('shapes');
    print('${box.length} shapes are saved');
    box.add(event.shape);

    List<Shape> shapes2 = box.toMap().values.toList().cast<Shape>();

    emit(state.copyWith(shapes: shapes2));
  }

  Future<void> _deleteShape(
      ShapeDeleted event, Emitter<ShapesPageState> emit) async {
    print('delete shape');
    List<Shape> shapes = state.shapes;
    int index = shapes.indexOf(event.shape);
    shapes.remove(event.shape);

    print('delete at index: $index');
    box.deleteAt(index);

  List<Shape> shapes2 = box.toMap().values.toList().cast<Shape>();

    emit(state.copyWith(shapes: shapes2));
  }

  void _editShape(ShapeEdited event, Emitter<ShapesPageState> emit) {
    List<Shape> shapes = state.shapes;
    int index = shapes.indexOf(event.shape);
    shapes.replaceRange(index, index, [event.shape]);
  }

  /// Called initially one time when the shapes page is created.
  FutureOr<void> _shapesPageCreated(
      ShapesPageCreated event, Emitter<ShapesPageState> emit) {
    print('shapes page created');
    List<Shape> shapes = box.toMap().values.toList().cast<Shape>();
    print('loaded {${shapes.length}} shapes');

    emit(state.copyWith(shapes: []));
    emit(state.copyWith(shapes: shapes));

  }

  void _saveShapesToDisk(ShapesSavedToDisk event, Emitter<ShapesPageState> emit) {
    print('save shapes to disk');
    box.close();
  }
}

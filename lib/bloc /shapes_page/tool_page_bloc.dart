import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../../model/simulation/tool.dart';
import '../../persistence/database_service.dart';

part 'tool_page_event.dart';

part 'tool_page_state.dart';

class ToolPageBloc extends Bloc<ToolPageEvent, ToolPageState> {
  DatabaseService _service = new DatabaseService();
  late Box box = Hive.box('shapes');

  ToolPageBloc() : super(ShapesPageInitial(shapes: [])) {
    on<ShapesPageCreated>(_shapesPageCreated);
    on<ShapeAdded>(_addShape);
    on<ShapeDeleted>(_deleteShape);
    on<ShapeEdited>(_editShape);
  }

  Future<void> _addShape(
      ShapeAdded event, Emitter<ToolPageState> emit) async {
    print('add shape shapes page bloc');
    List<Tool> shapes = state.tools;
    shapes.add(event.shape);

    Box box = await _service.createBox('shapes');
    print('${box.length} shapes are saved');
    box.add(event.shape);

    List<Tool> shapes2 = box.toMap().values.toList().cast<Tool>();

    emit(state.copyWith(shapes: shapes2));
  }

  Future<void> _deleteShape(
      ShapeDeleted event, Emitter<ToolPageState> emit) async {
    print('delete shape');
    List<Tool> shapes = state.tools;
    int index = shapes.indexOf(event.shape);
    shapes.remove(event.shape);

    print('delete at index: $index');
    box.deleteAt(index);

  List<Tool> shapes2 = box.toMap().values.toList().cast<Tool>();

    emit(state.copyWith(shapes: []));
    emit(state.copyWith(shapes: shapes2));
  }

  void _editShape(ShapeEdited event, Emitter<ToolPageState> emit) {
    List<Tool> shapes = state.tools;
    int index = shapes.indexOf(event.shape);
    shapes.replaceRange(index, index, [event.shape]);
  }

  /// Called initially one time when the shapes page is created.
  FutureOr<void> _shapesPageCreated(
      ShapesPageCreated event, Emitter<ToolPageState> emit) async {
    Box box = await _service.createBox('shapes');
    List<Tool> shapes = box.toMap().values.toList().cast<Tool>();
    print('loaded {${shapes.length}} shapes');

    emit(state.copyWith(shapes: shapes));
  }

}

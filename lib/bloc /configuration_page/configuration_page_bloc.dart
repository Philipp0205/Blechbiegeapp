import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../model/OffsetAdapter.dart';
import '../../model/line.dart';
import '../../model/segment_widget/segment.dart';
import '../../model/simulation/tool.dart';
import '../../model/simulation/tool_type.dart';

part 'configuration_page_event.dart';

part 'configuration_page_state.dart';

class ConfigPageBloc extends Bloc<ConfigurationPageEvent, ConfigPageState> {
  // ConstructingPageBloc() : super(ConstructingPageCreate(segment: [])) {
  ConfigPageBloc()
      : super(ConstructingPageInitial(
            segment: [],
            lines: [],
            shapes: [],
            showCoordinates: false,
            showEdgeLengths: false,
            showAngles: false,
            s: 5,
            r: 20)) {
    on<ConfigPageCreated>(_setInitialValues);
    on<ConfigCoordinatesShown>(_showCoordinates);
    on<ConfigEdgeLengthsShown>(_showEdgeLengths);
    on<ConfigAnglesShown>(_showAngles);
    on<ConfigCheckboxChanged>(_showDataDependingOnCheckbox);
    on<ConfigSChanged>(_changeThicknes);
    on<ConfigRChanged>(_changeRadius);
    on<ConfigShapeAdded>(_saveShape);
  }

  /// When no segment exists an initial segment gets created.
  Future<void> _setInitialValues(
      ConfigPageCreated event, Emitter<ConfigPageState> emit) async {
    emit(state.copyWith(lines: event.lines));
    _openShapesBox();
  }

  /// Registers all adapters needed to save shape objects in the database.
  Future<Box> _openShapesBox() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ToolAdapter());
    Hive.registerAdapter(LineAdapter());
    Hive.registerAdapter(OffsetAdapter());
    Hive.registerAdapter(ToolTypeAdapter());
    return await Hive.openBox('shapes');
  }

  /// Save [Tool] to hive database.
  void _saveShapeToDatabase(Tool shape) {
    print('save shape');
    Box box = Hive.box('shapes');
    box.add(shape);
    // emit(state.copyWith(shapes: event.shapes));
  }

  /// Decides depending on the [CheckBoxEnum] what should be shown.
  void _showDataDependingOnCheckbox(
      ConfigCheckboxChanged event, Emitter<ConfigPageState> emit) {
    switch (event.checkBox) {
      case CheckBoxEnum.coordinates:
        emit(state.copyWith(showCoordinates: event.checkBoxValue));
        break;
      case CheckBoxEnum.lengths:
        emit(state.copyWith(showEdgeLengths: event.checkBoxValue));
        break;
      case CheckBoxEnum.angles:
        emit(state.copyWith(showAngles: event.checkBoxValue));
        break;
    }
  }

  /// Handles event for showing the coordinates of each line on the canvas.
  void _showCoordinates(
      ConfigCoordinatesShown event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(showCoordinates: event.showCoordinates));
  }

  /// Handles event for showing the lengths of each line on the canvas.
  void _showEdgeLengths(
      ConfigEdgeLengthsShown event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(showEdgeLengths: event.showEdgeLengths));
  }

  /// Handles the event for showing the inner angles between liens on the canvas.
  void _showAngles(ConfigAnglesShown event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(showAngles: event.showAngles));
  }

  /// Handles event that changes the thickness of the line.
  void _changeThicknes(ConfigSChanged event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(s: event.s));
  }

  /// Handles the event that changes the radius of the curves that are drawn.j
  void _changeRadius(ConfigRChanged event, Emitter<ConfigPageState> emit) {
    emit(state.copyWith(r: event.r));
  }

  /// Saves a to the state (no DB involved here).
  Future<void> _saveShape(ConfigShapeAdded event, Emitter<ConfigPageState> emit) async {
    List<List<Line>> lines = state.shapes.map((shape) => shape.lines).toList();
    int index = lines.indexOf(event.shape.lines);
    List<Tool> shapes = state.shapes;

    if (_shapeAlreadyExists(event.shape, shapes)) {
      shapes
        ..removeAt(index)
        ..insert(index, event.shape);
    } else {
      print('shape does not exist');
      shapes.add(event.shape);
    }

    _saveShapeToDatabase(event.shape);

    print('emitted state ${shapes[0].name}');
    emit(state.copyWith(shapes: []));
  }

  bool _shapeAlreadyExists(Tool shape, List<Tool> shapes) {
    List<List<Line>> lines = shapes.map((shape) => shape.lines).toList();
    return lines.contains(shape.lines);
  }
}

enum CheckBoxEnum { coordinates, lengths, angles }

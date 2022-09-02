import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:open_bsp/bloc%20/simulation_page/simulation_page_bloc.dart';
import 'package:open_bsp/services/geometric_calculations_service.dart';

import '../../model/line.dart';
import '../../model/simulation/tool.dart';

import 'package:collection/collection.dart';

class SimulationSketcher extends CustomPainter {
  final List<Tool> beams;
  final List<Tool> tracks;
  final List<Tool> plates;
  final List<Offset> debugOffsets;
  final double rotateAngle;
  final BuildContext context;

  SimulationSketcher(
      {required this.beams,
      required this.tracks,
      required this.plates,
      required this.rotateAngle,
      required this.debugOffsets,
      required this.context});

  GeometricCalculationsService _calculationsService =
      new GeometricCalculationsService();

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    ui.PictureRecorder machineRecorder = new ui.PictureRecorder();
    ui.PictureRecorder plateRecorder = new ui.PictureRecorder();
    Canvas machineCanvas = new Canvas(machineRecorder);
    Canvas plateCanvas = new Canvas(plateRecorder);

    Paint blackPaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    Paint greyPaint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    Paint redStroke = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    Paint blackStroke = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    Paint blueStroke = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    Path beamsPath = new Path();
    Path tracksPath = new Path();
    Path platesPath = new Path();
    Path platesPath2 = new Path();

    // path.moveTo(testLine.start.dx, testLine.start.dy);
    // path.lineTo(testLine.end.dx, testLine.end.dy);

    // Create beams path
    if (beams.isNotEmpty) {
      beams.forEach((tool) {
        beamsPath.moveTo(tool.lines.first.start.dx, tool.lines.first.start.dy);
        tool.lines.forEach((line) {
          beamsPath.lineTo(line.end.dx, line.end.dy);
        });
      });
    }

    // Create tracks path
    if (tracks.isNotEmpty) {
      tracks.forEach((track) {
        tracksPath.moveTo(
            track.lines.first.start.dx, track.lines.first.start.dy);
        track.lines.forEach((line) {
          tracksPath.lineTo(line.end.dx, line.end.dy);
        });
      });
    }

    if (plates.isNotEmpty) {
      platesPath2.moveTo(
          plates.first.lines.first.start.dx, plates.first.lines.first.start.dy);
      plates.first.lines.forEach((line) {
        platesPath2.lineTo(line.end.dx, line.end.dy);
      });
    }

    if (plates.isNotEmpty) {
      List<Offset> plateOffsets =
          plates.first.lines.map((line) => line.start).toList() +
              plates.first.lines.map((line) => line.end).toList();

      Line? selectedLine =
          plates.first.lines.firstWhereOrNull((line) => line.isSelected);

      if (selectedLine == null) {
        selectedLine = plates.first.lines.first;
      }
      // Line middleLine = plates.first.lines[plates.first.lines.length ~/ 2];
      Offset center =
          _calculationsService.getMiddle(selectedLine.start, selectedLine.end);

      // canvas.drawCircle(center, 4, redStroke);

      List<Line> selectedLines = [];

      Tool selectedPlate = plates.first;

      selectedPlate.lines.forEach((line) {
        platesPath.moveTo(line.start.dx, line.start.dy);
        platesPath.lineTo(line.end.dx, line.end.dy);

        if (line.isSelected) {
          selectedLines.add(line);
        }
      });
    }

    Path machinePath = new Path();
    machinePath.addPath(beamsPath, new Offset(0, 0));
    machinePath.addPath(tracksPath, new Offset(0, 0));

    Path pPath = new Path();
    pPath.addPath(platesPath, new Offset(0, 0));

    machineCanvas.drawPath(beamsPath, blackPaint);
    machineCanvas.drawPath(tracksPath, blackPaint);
    plateCanvas.drawPath(platesPath, blackStroke);
    // plateCanvas.drawPath(platesPath2, blackPaint);

    // canvas.drawPath(machinePath, blackPaint);
    // canvas.drawPath(pPath, blueStroke);

    canvas.drawPath(beamsPath, blackPaint);

    canvas.drawPath(tracksPath, greyPaint);
    canvas.drawPath(platesPath2, blueStroke);

    debugOffsets.forEach((offset) {
      canvas.drawCircle(offset, 1, redStroke);
    });

    ui.Picture machinePicture = machineRecorder.endRecording();
    List<Offset> machineOffsets = await createPicture(
        machinePicture, machineRecorder, size, machinePath, Colors.black);

    ui.Picture platePicture = plateRecorder.endRecording();
    List<Offset> plateOffsets = await createPicture(
        platePicture, plateRecorder, size, pPath, Colors.black);

    _detectCollision(machineOffsets, plateOffsets);
  }

  /// Returns all black pixel of the canvas.
  Future<List<Offset>> createPicture(
      Picture picture,
      ui.PictureRecorder recorder,
      Size size,
      Path path,
      Color checkedColor) async {
    // ui.Picture picture = pictureRecorder.endRecording();
    ui.Image image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    // ByteData? data = await image.toByteData();
    ByteData? data2 =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    List<Offset> collisionOffsets = [];

    img.Image newImage = img.Image.fromBytes(
        size.width.toInt(), size.height.toInt(), data2!.buffer.asUint8List());

    for (int x = 0; x < size.width.toInt(); ++x) {
      for (int y = 0; y < size.height.toInt(); ++y) {
        int color = newImage.getPixel(x, y);

        if (Color(color) == checkedColor) {
          collisionOffsets.add(new Offset(x.toDouble(), y.toDouble()));
        }
      }
    }

    return collisionOffsets;
  }

  void _detectCollision(
      List<Offset> collisionOffsets, List<Offset> plateOffsets) {
    SimulationPageState state = context.read<SimulationPageBloc>().state;

    this.context.read<SimulationPageBloc>().add(SimulationCollisionDetected(
        collisionOffsets: collisionOffsets, plateOffsets: plateOffsets));

    if (state.isSimulationRunning == true) {
      this.context.read<SimulationPageBloc>().add(SimulationTicked());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

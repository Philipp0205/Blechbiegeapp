import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:open_bsp/repository/segments_provider.dart';
import 'package:open_bsp/repository/segments_repository.dart';

void bootstrap({required SegmentsProvider segmentsProvider}) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  final SegmentsResposiory segmentsResposiory = new SegmentsResposiory(segmentsProvider: segmentsProvider);


}
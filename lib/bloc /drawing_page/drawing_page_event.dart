part of 'drawing_page_bloc.dart';

abstract class DrawingPageEvent extends Equatable {
  DrawingPageEvent();

  @override
  List<Object> get props => [];
}

class DrawingPageModeChanged extends DrawingPageEvent {
  final Mode mode;
  DrawingPageModeChanged({required this.mode});
}

class DrawingPageSelectionModeChanged extends DrawingPageEvent {
  final bool selectionMode;
  DrawingPageSelectionModeChanged({required this.selectionMode});
}



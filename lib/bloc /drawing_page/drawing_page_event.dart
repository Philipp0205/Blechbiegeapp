part of 'drawing_page_bloc.dart';

abstract class DrawingPageEvent extends Equatable {
  DrawingPageEvent();

  @override
  List<Object> get props => [];
}

class DrawingPageModeSelectionPressed extends DrawingPageEvent {
  final Mode mode;
  DrawingPageModeSelectionPressed({required this.mode});

}

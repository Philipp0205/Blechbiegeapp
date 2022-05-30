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

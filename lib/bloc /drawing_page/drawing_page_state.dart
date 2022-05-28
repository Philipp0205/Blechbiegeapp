part of 'drawing_page_bloc.dart';

@immutable
abstract class DrawingPageState {
  final Mode mode;

  const DrawingPageState({required this.mode});
}

class DrawingPageInitial extends DrawingPageState {
  final Mode mode;

  const DrawingPageInitial({required this.mode}) : super(mode: mode);
}

class ModeSelectionSuccess extends DrawingPageState {
  final Mode mode;
  const ModeSelectionSuccess({required this.mode}) : super(mode: mode);

}

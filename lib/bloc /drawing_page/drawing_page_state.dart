part of 'drawing_page_bloc.dart';

@immutable
class DrawingPageState extends Equatable {
  final Mode mode;
  final bool selectionMode;

  const DrawingPageState({required this.mode, required this.selectionMode});


  DrawingPageState copyWith({
    Mode? mode,
    bool? selectionMode,
  }) {
    return DrawingPageState(
      mode: mode ?? this.mode,
      selectionMode: selectionMode ?? this.selectionMode,
    );
  }
  @override
  List<Object> get props => [selectionMode];
}

class DrawingPageInitial extends DrawingPageState {
  final Mode mode;
  final bool selectionMode;

  const DrawingPageInitial({required this.mode, required this.selectionMode})
      : super(mode: mode, selectionMode: selectionMode);

}

// class ModeSelectionSuccess extends DrawingPageState {
//   final Mode mode;
//   const ModeSelectionSuccess({required this.mode}) : super(mode: mode);
//
// }

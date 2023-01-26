part of 'drawing_page_bloc.dart';

@immutable
class DrawingPageState extends Equatable {
  final Mode mode;
  final bool selectionMode;
  final bool setAdapterMode;

  const DrawingPageState({
    required this.mode,
    required this.selectionMode,
    required this.setAdapterMode,
  });

  @override
  List<Object> get props => [selectionMode];

  DrawingPageState copyWith({
    Mode? mode,
    bool? selectionMode,
    bool? setAdapterMode,
  }) {
    return DrawingPageState(
      mode: mode ?? this.mode,
      selectionMode: selectionMode ?? this.selectionMode,
      setAdapterMode: setAdapterMode ?? this.setAdapterMode,
    );
  }
}

class DrawingPageInitial extends DrawingPageState {
  final Mode mode;
  final bool selectionMode;
  final bool setAdapterMode;

  final double currentAngle;
  final double currentLength;

  const DrawingPageInitial(
      {required this.mode,
      required this.selectionMode,
      required this.setAdapterMode,
      required this.currentAngle,
      required this.currentLength})
      : super(
          mode: mode,
          selectionMode: selectionMode,
          setAdapterMode: setAdapterMode,
        );
}

// class ModeSelectionSuccess extends DrawingPageState {
//   final Mode mode;
//   const ModeSelectionSuccess({required this.mode}) : super(mode: mode);
//
// }

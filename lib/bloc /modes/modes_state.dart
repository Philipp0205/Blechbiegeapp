
import 'package:equatable/equatable.dart';
import 'package:open_bsp/model/appmodes.dart';

abstract class ModesState extends Equatable {
  final Mode mode;

  const ModesState({required this.mode});

  @override
  List<Object> get props => [];
}

class ModesInitial extends ModesState {
  final Mode mode;
  const ModesInitial({required this.mode}) : super(mode: mode);
}

class ModeUpdate extends ModesState {
  final Mode mode;
  const ModeUpdate({required this.mode}) : super(mode: mode);
}


part of 'simulation_page_bloc.dart';

abstract class SimulationPageState extends Equatable {
  final Shape lowerBeam;
  final Shape upperBeam;
  final Shape bendingBeam;

  const SimulationPageState(
      {required this.lowerBeam,
      required this.upperBeam,
      required this.bendingBeam});

  @override
  List<Object> get props => [lowerBeam, upperBeam, bendingBeam];
}


/// Initial values when the Bloc is created the first time.
class SimulationPageInitial extends SimulationPageState {
  SimulationPageInitial(
      {required Shape lowerBeam,
      required Shape upperBeam,
      required Shape bendingBeam})
      : super(
            lowerBeam: lowerBeam,
            upperBeam: upperBeam,
            bendingBeam: bendingBeam);
}



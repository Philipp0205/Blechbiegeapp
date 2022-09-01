import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/ticker_widget/timer_widget_bloc.dart';

import '../../bloc /simulation_page/simulation_page_bloc.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TickerWidgetState();
}

class _TickerWidgetState extends State<TimerWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerWidgetBloc, TimerWidgetState>(
      builder: (context, state) {
        return TimerText();
      },
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerWidgetBloc bloc) => bloc.state.duration);
    final minutesStr =
    ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    // context.read<SimulationPageBloc>().add(SimulationTicked());



    return Text(
      '$minutesStr:$secondsStr',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

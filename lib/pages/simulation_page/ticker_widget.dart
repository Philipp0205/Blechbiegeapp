import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_bsp/bloc%20/ticker_widget/timer_widget_bloc.dart';

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
        return Text(
          'Test',
        );
      },
    );
  }
}

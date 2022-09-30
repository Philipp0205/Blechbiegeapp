import 'package:flutter/cupertino.dart';

class TwoColumnLayout extends StatelessWidget {
  final Column leftColumn;
  final Column rightColumn;

  const TwoColumnLayout({
    Key? key,
    required this.leftColumn,
    required this.rightColumn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: leftColumn,
          ),
        ),
        Flexible(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: rightColumn,
          ),
        ),
      ],
    );
  }
}

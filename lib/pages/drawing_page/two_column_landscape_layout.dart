import 'package:flutter/cupertino.dart';

class TwoColumnLandscapeLayout extends StatelessWidget {
  final Column leftColumn;
  final Column rightColumn;

  const TwoColumnLandscapeLayout({
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

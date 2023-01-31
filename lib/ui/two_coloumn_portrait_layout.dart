import 'package:flutter/cupertino.dart';

class TwoColumnPortraitLayout extends StatelessWidget {
  final Row upperRow;
  final Column lowerColumn;

  const TwoColumnPortraitLayout(
      {Key? key, required this.upperRow, required this.lowerColumn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Flexible(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: upperRow,
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: lowerColumn,
            ),
          ),
        ],
      ),
    );
  }
}

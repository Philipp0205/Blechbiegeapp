import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        VerticalDivider(),
        Text('Smartbend by Dr. Hochstrate'),
        SizedBox(width: 10),
        Image.asset(
          'assets/images/logo-hochstrate.png',
          width: 170,
        ),
      ],
    );
  }
}

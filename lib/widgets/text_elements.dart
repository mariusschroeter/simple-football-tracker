import 'package:flutter/material.dart';

class NormalTextSize extends StatelessWidget {
  final String title;

  NormalTextSize(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 22),
    );
  }
}

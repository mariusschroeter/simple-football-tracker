import 'package:flutter/material.dart';

class NormalTextSize extends StatelessWidget {
  final String title;
  final Color color;

  NormalTextSize({this.title, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, color: color),
    );
  }
}

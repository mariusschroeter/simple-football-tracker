import 'package:flutter/material.dart';

class NormalTextSize extends StatelessWidget {
  final String title;
  final Color color;
  final double padding;
  final double size;

  NormalTextSize({
    this.title,
    this.color = Colors.black,
    this.padding = 0.0,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text(
        title,
        style: TextStyle(fontSize: size, color: color),
      ),
    );
  }
}

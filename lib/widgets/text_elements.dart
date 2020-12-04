import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/global_colors.dart';

class NormalTextSize extends StatelessWidget {
  final String title;
  final Color color;
  final EdgeInsets padding;
  final double size;

  NormalTextSize({
    this.title,
    this.color = Colors.black,
    this.padding = const EdgeInsets.all(0.0),
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: TextStyle(fontSize: size, color: color),
      ),
    );
  }
}

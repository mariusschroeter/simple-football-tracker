import 'package:flutter/material.dart';
import 'package:simple_football_tracker/widgets/svg.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Svg(
          name: 'logo',
        ),
      ),
    );
  }
}

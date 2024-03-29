import 'package:flutter/material.dart';

class MatchGoal extends StatelessWidget {
  final Function onShot;
  // final Function onWillAcceptShot;
  final Function setColorOnShot;
  final bool isHomeShot;
  // final Color color;

  MatchGoal({
    this.onShot,
    this.isHomeShot,
    this.setColorOnShot,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<double>(
      builder: (context, candidates, rejects) {
        return Container(
          height: 70,
          width: 200,
        );
      },
      onAccept: (_) => onShot(isHomeShot),
      onWillAccept: (_) => setColorOnShot(1.0, isHomeShot),
      onLeave: (_) => setColorOnShot(0.4, isHomeShot),
    );
  }
}

import 'package:flutter/material.dart';

class MatchGoal extends StatelessWidget {
  final Function onShot;
  // final Function onWillAcceptShot;
  // final Function setGoalColor;
  final bool isHomeShot;
  // final Color color;

  MatchGoal({
    this.onShot,
    this.isHomeShot,
    // this.onWillAcceptShot,
    // this.color,
    // this.setGoalColor,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Color>(
      builder: (context, candidates, rejects) {
        return Container(
          // color: color,
          height: 23,
          width: 60,
        );
      },
      onAccept: (_) => onShot(isHomeShot),
      // onWillAccept: (_) => onWillAcceptShot(!isHomeShot),
      // onLeave: (_) => setGoalColor(Colors.transparent),
    );
  }
}

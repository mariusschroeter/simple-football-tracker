import 'package:flutter/material.dart';

class MatchGoal extends StatelessWidget {
  final Function onShot;
  final bool isHomeShot;

  MatchGoal({this.onShot, this.isHomeShot});

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (context, candidates, rejects) {
        return Container(
          height: 25,
          width: 60,
        );
      },
      onAccept: (_) => onShot(isHomeShot),
    );
  }
}

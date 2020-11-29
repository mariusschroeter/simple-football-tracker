import 'package:flutter/material.dart';

class MatchBall extends StatelessWidget {
  MatchBall({this.color, this.ballPosition});

  final Offset ballPosition;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: ballPosition.dy,
      left: ballPosition.dx,
      child: Draggable(
        // onDraggableCanceled:
        //     (Velocity velocity, Offset offset) {
        // },

        child: Container(
          height: 35,
          width: 35,
          color: Colors.transparent,
          child: Icon(
            Icons.sports_soccer,
            color: color,
          ),
        ),
        feedback: Icon(
          Icons.sports_soccer,
          color: color,
        ),
        childWhenDragging: Icon(
          Icons.sports_soccer,
          color: color.withOpacity(0.5),
        ),
      ),
    );
  }
}

class MatchGoal extends StatelessWidget {
  final Function onShot;
  final bool isHomeShot;

  MatchGoal({this.onShot, this.isHomeShot});

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (context, candidates, rejects) {
        return Container(
          height: 40,
          width: 40,
          color: Colors.green,
        );
      },
      onAccept: (value) => onShot(isHomeShot),
    );
  }
}

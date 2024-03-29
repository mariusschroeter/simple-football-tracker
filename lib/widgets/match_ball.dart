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
      child: Draggable<double>(
        data: 0.4,
        child: Container(
          height: 35,
          width: 35,
          color: Colors.transparent,
          child: Icon(
            Icons.sports_soccer,
            color: color,
            size: 32,
          ),
        ),
        feedback: Icon(
          Icons.sports_soccer,
          color: color,
          size: 32,
        ),
        childWhenDragging: Icon(
          Icons.sports_soccer,
          color: color.withOpacity(0.5),
          size: 32,
        ),
      ),
    );
  }
}

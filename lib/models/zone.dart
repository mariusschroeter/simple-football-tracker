import 'package:flutter/material.dart';

class Zone extends ZonePercentages {
  Color color;
  double xStart;
  double xEnd;
  double yStart;
  double yEnd;

  Zone({
    homePercentage,
    awayPercentage,
    color,
    this.xStart,
    this.xEnd,
    this.yStart,
    this.yEnd,
  }) : super(
          homePercentage: homePercentage,
          awayPercentage: awayPercentage,
        );
}

class ZonePercentages {
  int minute;
  double homePercentage;
  double awayPercentage;

  ZonePercentages({this.minute, this.homePercentage, this.awayPercentage});
}

class Zone extends ZonePercentages {
  double xStart;
  double xEnd;
  double yStart;
  double yEnd;

  Zone({
    homePercentage,
    awayPercentage,
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
  double homePercentage;
  double awayPercentage;

  ZonePercentages({this.homePercentage, this.awayPercentage});
}

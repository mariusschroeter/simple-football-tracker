import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/text_elements.dart';

class FieldZone extends StatelessWidget {
  const FieldZone({
    Key key,
    this.homePercentage,
    this.awayPercentage,
    this.isTotalZone = false,
  }) : super(key: key);

  final double homePercentage;
  final double awayPercentage;
  final bool isTotalZone;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          height: isTotalZone ? 100 : 250,
          width: screenWidth / 3,
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NormalTextSize(
                color: Colors.white,
                title: '${homePercentage.toStringAsFixed(2)}%',
              ),
              NormalTextSize(
                color: Colors.black,
                title: '${awayPercentage.toStringAsFixed(2)}%',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FieldZoneRow extends StatelessWidget {
  const FieldZoneRow({
    @required this.zoneCount,
    @required this.percentages,
  });

  final int zoneCount;
  final List<List<double>> percentages;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, i) => FieldZone(
          homePercentage: percentages[0][i],
          awayPercentage: percentages[1][i],
        ),
        itemCount: zoneCount,
      ),
    );
  }
}

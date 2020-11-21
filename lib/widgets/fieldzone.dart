import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/text_elements.dart';

class FieldZone extends StatelessWidget {
  const FieldZone({
    Key key,
    this.homePercentage,
    this.awayPercentage,
    this.isTotalZone = false,
    this.color = Colors.green,
  }) : super(key: key);

  final double homePercentage;
  final double awayPercentage;
  final bool isTotalZone;
  final Color color;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          color: homePercentage != null ? Colors.transparent : color,
          height: isTotalZone ? 100 : 250,
          width: screenWidth / 3,
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NormalTextSize(
                color: Colors.white,
                title: homePercentage != null
                    ? '${homePercentage.toStringAsFixed(2)}%'
                    : '',
              ),
              NormalTextSize(
                color: Colors.black,
                title: awayPercentage != null
                    ? '${awayPercentage.toStringAsFixed(2)}%'
                    : '',
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
    this.colors,
  });

  final int zoneCount;
  final List<List<double>> percentages;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, i) => FieldZone(
          homePercentage: percentages != null ? percentages[0][i] : null,
          awayPercentage: percentages != null ? percentages[1][i] : null,
          color: colors[i],
        ),
        itemCount: zoneCount,
      ),
    );
  }
}

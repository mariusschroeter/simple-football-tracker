import 'package:flutter/material.dart';
import 'package:football_provider_app/models/zone.dart';
import 'package:football_provider_app/widgets/text_elements.dart';

class FieldZone extends StatelessWidget {
  const FieldZone({
    Key key,
    this.homePercentage,
    this.awayPercentage,
    this.isTotalZone = false,
    this.color = Colors.green,
    this.showColor = false,
    this.showPercentages = false,
  }) : super(key: key);

  final double homePercentage;
  final double awayPercentage;
  final bool isTotalZone;
  final Color color;
  final bool showColor;
  final bool showPercentages;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Color colorAdjust = homePercentage != null
        ? color.withOpacity(homePercentage / 100)
        : color.withOpacity(0.1);
    return Stack(
      children: [
        Container(
          color: showColor ? colorAdjust : Colors.transparent,
          height: isTotalZone ? 100 : 250,
          width: screenWidth / 3,
        ),
        showPercentages
            ? Positioned.fill(
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
              )
            : SizedBox(),
      ],
    );
  }
}

class FieldZoneRow extends StatelessWidget {
  const FieldZoneRow({
    @required this.zoneCount,
    @required this.percentages,
    this.colors,
    this.showColor,
    this.showPercentages,
  });

  final int zoneCount;
  final List<List<double>> percentages;
  final List<Color> colors;
  final bool showColor;
  final bool showPercentages;
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
          showColor: showColor,
          showPercentages: showPercentages,
        ),
        itemCount: zoneCount,
      ),
    );
  }
}

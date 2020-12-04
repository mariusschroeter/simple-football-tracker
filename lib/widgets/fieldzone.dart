import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:football_provider_app/widgets/text_elements.dart';

class FieldZone extends StatelessWidget {
  const FieldZone({
    Key key,
    this.homePercentage,
    this.awayPercentage,
    this.isTotalZone = false,
    this.showPercentages = false,
    this.showHeatMap = false,
  }) : super(key: key);

  final double homePercentage;
  final double awayPercentage;
  final bool isTotalZone;
  final bool showPercentages;
  final bool showHeatMap;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final color = !showHeatMap
        ? Colors.transparent
        : homePercentage <= 10
            ? Colors.green.withOpacity(homePercentage / 100 + 0.2)
            : homePercentage <= 20 && homePercentage > 10
                ? Colors.yellow.withOpacity(homePercentage / 100)
                : homePercentage > 20
                    ? Colors.red.withOpacity(homePercentage / 100 - 0.1)
                    : Colors.transparent;
    return Stack(
      children: [
        Container(
          color: color,
          height: isTotalZone ? 100 : 250,
          width: screenWidth / 3,
        ),
        showPercentages
            ? Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      decoration: BoxDecoration(
                          color: GlobalColors.primary.withOpacity(0.1),
                          border: Border.all(width: 0.1, color: Colors.white)),
                      child: Text(
                        '${homePercentage.toStringAsFixed(2)}%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    Container(
                      width: 90,
                      decoration: BoxDecoration(
                          color: GlobalColors.secondary.withOpacity(0.1),
                          border: Border.all(width: 0.1, color: Colors.white)),
                      child: Text(
                        '${awayPercentage.toStringAsFixed(2)}%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
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
    this.showPercentages = false,
    this.showHeatMap = false,
  });

  final int zoneCount;
  final List<List<double>> percentages;
  final bool showPercentages;
  final bool showHeatMap;

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
          showPercentages: showPercentages,
          showHeatMap: showHeatMap,
        ),
        itemCount: zoneCount,
      ),
    );
  }
}

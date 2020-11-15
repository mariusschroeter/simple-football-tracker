import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/text_elements.dart';

class FieldZone extends StatelessWidget {
  const FieldZone({
    Key key,
    this.setZoneActive,
    this.line,
    this.column,
    this.homePercentage,
    this.awayPercentage,
  }) : super(key: key);

  final dynamic setZoneActive;
  final int line;
  final int column;
  final double homePercentage;
  final double awayPercentage;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTapDown: (TapDownDetails details) =>
          setZoneActive(line, column, details),
      child: Stack(
        children: [
          Container(
            color: Colors.transparent,
            height: 250,
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
      ),
    );
  }
}

class FieldZoneRow extends StatelessWidget {
  const FieldZoneRow({
    @required this.setZoneActive,
    @required this.line,
    @required this.zoneCount,
    @required this.percentages,
  });

  final dynamic setZoneActive;
  final int line;
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
          setZoneActive: setZoneActive,
          line: line,
          column: i,
          homePercentage: percentages[0][i],
          awayPercentage: percentages[1][i],
        ),
        itemCount: zoneCount,
      ),
    );
  }
}

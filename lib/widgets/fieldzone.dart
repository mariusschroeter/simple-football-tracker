import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/text_elements.dart';

class FieldZone extends StatelessWidget {
  const FieldZone({
    Key key,
    this.setZoneActive,
    this.line,
    this.column,
    this.percentage,
  }) : super(key: key);

  final dynamic setZoneActive;
  final int line;
  final int column;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () => setZoneActive(line, column),
      child: Stack(
        children: [
          Container(
            color: Colors.lightGreen,
            height: 250,
            width: screenWidth / 3,
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NormalTextSize(
                  color: Colors.white,
                  title: '${percentage.toStringAsFixed(2)}%',
                ),
                NormalTextSize(title: '10%'),
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
  final List<double> percentages;

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
          percentage: percentages[i],
        ),
        itemCount: zoneCount,
      ),
    );
  }
}

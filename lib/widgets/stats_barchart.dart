import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/global_colors.dart';

class StatsBarchart extends StatelessWidget {
  final String title;
  final num homeValue;
  final num awayValue;

  StatsBarchart({this.title, this.homeValue, this.awayValue});

  @override
  Widget build(BuildContext context) {
    final homeValueFormatted = homeValue.toStringAsFixed(0);
    final awayValueFormatted = awayValue.toStringAsFixed(0);
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: 30,
                    child: Text(
                      '$homeValueFormatted',
                      textAlign: TextAlign.left,
                    )),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    child: CustomPaint(
                        painter: StatsBarchartPainter(
                            homeValue: homeValue, awayValue: awayValue)),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Container(
                    width: 30,
                    child: Text(
                      '$awayValueFormatted',
                      textAlign: TextAlign.right,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatsBarchartPainter extends CustomPainter {
  StatsBarchartPainter({this.homeValue, this.awayValue});

  final num homeValue;
  final num awayValue;

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2 - 8);
    Offset centerParallel = Offset(size.width / 2, size.height / 2 + 8);
    final totalValue = homeValue + awayValue;
    final homePercentageOfTotalValue =
        homeValue != 0 ? homeValue / totalValue : 0;
    final homeBarWidth = size.width / 2 * homePercentageOfTotalValue;
    final homeBarPos =
        Offset(size.width / 2 - homeBarWidth - 1, size.height / 2 - 6);
    final awayPercentageOfTotalValue =
        awayValue != 0 ? awayValue / totalValue : 0;
    final awayBarWidth = size.width / 2 * awayPercentageOfTotalValue;
    final awayBarPos = Offset(size.width / 2 + 1, size.height / 2 - 6);

    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5
      ..style = PaintingStyle.fill;

    canvas.drawLine(center, centerParallel, paint);
    paint = paint..color = GlobalColors.primary;
    canvas.drawRect(homeBarPos & Size(homeBarWidth, 12), paint);
    paint = paint..color = GlobalColors.accent;
    canvas.drawRect(awayBarPos & Size(awayBarWidth, 12), paint);
  }

  @override
  bool shouldRepaint(StatsBarchartPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(StatsBarchartPainter oldDelegate) => false;
}

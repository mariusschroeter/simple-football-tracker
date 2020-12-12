import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/global_colors.dart';

class Scoreboard extends StatelessWidget {
  final String time;
  final String extraTime;
  final String homeTeam;
  final String awayTeam;
  final int homeGoals;
  final int awayGoals;
  final double opacityOfHomeTeam;
  final double opacityOfAwayTeam;

  Scoreboard({
    @required this.time,
    this.extraTime = '',
    @required this.homeTeam,
    @required this.awayTeam,
    @required this.homeGoals,
    @required this.awayGoals,
    this.opacityOfHomeTeam = 0.4,
    this.opacityOfAwayTeam = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: Border.all(
        width: 0.5,
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(top: 8, right: 8, bottom: 8, left: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: GlobalColors.primary
                              .withOpacity(opacityOfHomeTeam),
                          border: Border.all(width: 0.1, color: Colors.white)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          homeTeam.toUpperCase(),
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    Text(
                      homeGoals.toString(),
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      time,
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      extraTime,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: GlobalColors.secondary
                              .withOpacity(opacityOfAwayTeam),
                          border: Border.all(width: 0.1, color: Colors.white)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          awayTeam.toUpperCase(),
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    Text(
                      awayGoals.toString(),
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

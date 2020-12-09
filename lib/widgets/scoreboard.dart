import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/global_colors.dart';

class Scoreboard extends StatelessWidget {
  final String time;
  final String extraTime;
  final String homeTeam;
  final String awayTeam;
  final int homeGoals;
  final int awayGoals;

  Scoreboard({
    this.time,
    this.extraTime,
    this.homeTeam,
    this.awayTeam,
    this.homeGoals,
    this.awayGoals,
  });

  @override
  Widget build(BuildContext context) {
    final homeTeamFormatted = homeTeam.substring(0, 3).toUpperCase();
    final awayTeamFormatted = awayTeam.substring(0, 3).toUpperCase();
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
                          color: GlobalColors.primary.withOpacity(0.1),
                          border: Border.all(width: 0.1, color: Colors.white)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          homeTeamFormatted,
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
                          color: GlobalColors.secondary.withOpacity(0.1),
                          border: Border.all(width: 0.1, color: Colors.white)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          awayTeamFormatted,
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

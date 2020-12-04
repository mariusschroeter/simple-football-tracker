import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:intl/intl.dart';

class Scoreboard extends StatelessWidget {
  final bool isLive;
  final String homeTeam;
  final String awayTeam;
  final int homeGoals;
  final int awayGoals;

  Scoreboard({
    this.isLive = false,
    this.homeTeam,
    this.awayTeam,
    this.homeGoals,
    this.awayGoals,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: Border.all(
        width: 0.5,
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: GlobalColors.primary.withOpacity(0.1),
                            border:
                                Border.all(width: 0.1, color: Colors.white)),
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
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    Text(
                      '45:00',
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '45:00',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: GlobalColors.secondary.withOpacity(0.1),
                            border:
                                Border.all(width: 0.1, color: Colors.white)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            awayTeam.toUpperCase(),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.only(top: 8, right: 4, bottom: 8, left: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0, right: 4.0),
                child: Text(
                  DateFormat('dd.MM.yyyy').format(DateTime.now()),
                ),
              ),
            ],
          ),
          ListTile(
            leading: Text('15:00'),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(flex: 1, child: Text(homeTeam)),
                    Text(homeGoals.toString())
                  ],
                ),
                Row(
                  children: [
                    Expanded(flex: 1, child: Text(awayTeam)),
                    Text(awayGoals.toString())
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

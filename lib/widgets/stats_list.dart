import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/stats_barchart.dart';

class StatsList extends StatelessWidget {
  final List<dynamic> stats;

  StatsList({this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemBuilder: (ctx, i) => StatsBarchart(
          title: stats[i].title,
          homeValue: stats[i].values[0],
          awayValue: stats[i].values[1],
          isPossession: i == 0,
        ),
        itemCount: stats.length,
        shrinkWrap: true,
      ),
    );
  }
}

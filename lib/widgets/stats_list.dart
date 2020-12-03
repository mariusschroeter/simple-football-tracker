import 'package:flutter/material.dart';
import 'package:football_provider_app/screens/add_match_start_match.screen.dart';
import 'package:football_provider_app/widgets/stats_barchart.dart';

class StatsList extends StatelessWidget {
  final Map<String, List<num>> stats;

  StatsList({this.stats});

  @override
  Widget build(BuildContext context) {
    final statsList = stats.entries
        .map((e) => BarchartStat(title: e.key, values: e.value))
        .toList();
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, i) => StatsBarchart(
          title: statsList[i].title,
          homeValue: statsList[i].values[0],
          awayValue: statsList[i].values[1],
        ),
        itemCount: statsList.length,
        shrinkWrap: true,
      ),
    );
  }
}

class BarchartStat {
  String title;
  List<num> values;

  BarchartStat({this.title, this.values});
}

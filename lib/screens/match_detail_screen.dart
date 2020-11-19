import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/simple_linechart.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../providers/matches.dart';

class MatchDetailScreen extends StatelessWidget {
  static const routeName = "/match-detail";

  //Hier kommen dann die ganzen Statistiken rein
  //Einfach ein Graph der auch die Highlights enthält(Wann ist ein Tor gefallen)
  @override
  Widget build(BuildContext context) {
    final matchId = ModalRoute.of(context).settings.arguments as String;
    final loadedMatch =
        Provider.of<MatchesProvider>(context, listen: false).findById(matchId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedMatch.homeTeam),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 300,
          child: Column(
            children: [
              //Easy lineChart
              Container(
                height: 200,
                child: charts.LineChart(
                  _createSampleData(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Create one series with sample hard coded data.
List<charts.Series<LinearPossessions, int>> _createSampleData() {
  final fakeHome = [
    new LinearPossessions(5, 45),
    new LinearPossessions(15, 55),
    new LinearPossessions(30, 45),
    new LinearPossessions(45, 50),
  ];
  final fakeAway = [
    new LinearPossessions(5, 55),
    new LinearPossessions(15, 45),
    new LinearPossessions(30, 55),
    new LinearPossessions(45, 50),
  ];

  return [
    new charts.Series<LinearPossessions, int>(
      id: 'Home',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (LinearPossessions possession, _) => possession.minute,
      measureFn: (LinearPossessions possession, _) => possession.possession,
      data: fakeHome,
    ),
    new charts.Series<LinearPossessions, int>(
      id: 'Away',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (LinearPossessions possession, _) => possession.minute,
      measureFn: (LinearPossessions possession, _) => possession.possession,
      data: fakeAway,
    ),
  ];
}

class LinearPossessions {
  final int minute;
  final int possession;

  LinearPossessions(this.minute, this.possession);
}

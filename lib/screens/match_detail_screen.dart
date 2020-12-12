import 'package:flutter/material.dart';
import 'package:football_provider_app/models/zone.dart';
import 'package:football_provider_app/widgets/fieldzone.dart';
import 'package:football_provider_app/widgets/text_elements.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/matches.dart';

class MatchDetailScreen extends StatelessWidget {
  static const routeName = "/match-detail";

  ZoneStats getZonePercentages(List<ZonePercentages> zones, int line) {
    List<double> homePercentages = [];
    List<double> awayPercentages = [];
    int indexStart = (line - 1) * 3;
    int indexEnd = line * 3;
    for (var i = indexStart; i < indexEnd; i++) {
      homePercentages.add(zones[i].homePercentage);
    }
    for (var i = indexStart; i < indexEnd; i++) {
      awayPercentages.add(zones[i].awayPercentage);
    }
    List<List<double>> percentages = [
      homePercentages,
      awayPercentages,
    ];
    ZoneStats stats = ZoneStats(percentages: percentages);
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final matchId = ModalRoute.of(context).settings.arguments as String;
    final loadedMatch =
        Provider.of<MatchesProvider>(context, listen: false).findById(matchId);
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd.MM.yyyy').format(loadedMatch.dateTime)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
                child: Text('1st Half',
                    style: Theme.of(context).textTheme.headline1)),
            Container(
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/resources/images/football_field.jpg"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: NormalTextSize(
                      title: loadedMatch.homeTeam,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 450,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (ctx, i) => Container(
                              height: 450 / 2,
                              child: FieldZoneRow(
                                showPercentages: true,
                                zoneCount: 3,
                                percentages: getZonePercentages(
                                  loadedMatch.firstHalfZones,
                                  i + 1,
                                ).percentages,
                                innerFieldHeight: 450,
                              ),
                            ),
                            itemCount: 2,
                          ),
                          //Zone end ---
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: NormalTextSize(
                          title: loadedMatch.awayTeam,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Center(
                child: Text('2nd Half',
                    style: Theme.of(context).textTheme.headline1)),
            Container(
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/resources/images/football_field.jpg"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: NormalTextSize(
                        title: loadedMatch.homeTeam,
                        color: Colors.white,
                      )),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 450,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (ctx, i) => Container(
                              height: 450 / 2,
                              child: FieldZoneRow(
                                showPercentages: true,
                                zoneCount: 3,
                                percentages: getZonePercentages(
                                  loadedMatch.secondHalfZones,
                                  i + 1,
                                ).percentages,
                                innerFieldHeight: 450,
                              ),
                            ),
                            itemCount: 2,
                          ),
                          //Zone end ---
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: NormalTextSize(
                          title: loadedMatch.awayTeam,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

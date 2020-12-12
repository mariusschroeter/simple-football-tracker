import 'package:flutter/material.dart';
import 'package:football_provider_app/models/zone.dart';
import 'package:football_provider_app/widgets/fieldzone.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:football_provider_app/widgets/scoreboard.dart';
import 'package:football_provider_app/widgets/text_elements.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/matches.dart';

class MatchDetailScreen extends StatefulWidget {
  static const routeName = "/match-detail";

  @override
  _MatchDetailScreenState createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _scoreboardRowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initField();
    });
  }

  double _screenWidth = 0;
  double _screenHeight = 0;
  double _fieldHeight = 0;

  _initField() {
    setState(() {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
      final _statusBarHeight = MediaQuery.of(context).padding.top;
      _fieldHeight = _screenHeight -
          _statusBarHeight -
          _scoreboardRowKey.currentContext.size.height;
    });
  }

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

    final appBar = AppBar(
      title: Text(DateFormat('dd.MM.yyyy').format(loadedMatch.dateTime)),
    );

    final fieldHeight = _fieldHeight - appBar.preferredSize.height;
    final innerFieldHeight = fieldHeight - 46;
    return Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
            child: Column(children: [
          Row(
            key: _scoreboardRowKey,
            children: [
              Expanded(
                flex: 1,
                child: Scoreboard(
                  time: '90:00',
                  homeTeam: loadedMatch.homeTeamAbb,
                  awayTeam: loadedMatch.awayTeamAbb,
                  homeGoals: loadedMatch.score[0],
                  awayGoals: loadedMatch.score[1],
                ),
              ),
            ],
          ),
          Container(
            height: fieldHeight,
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
                  child: Container(
                    color: GlobalColors.primary.withOpacity(0.4),
                    height: 23.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: NormalTextSize(
                        title: loadedMatch.homeTeamAbb,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: innerFieldHeight,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, i) => Container(
                            height: innerFieldHeight / 2,
                            child: FieldZoneRow(
                              showPercentages: true,
                              zoneCount: 3,
                              percentages: getZonePercentages(
                                loadedMatch.firstHalfZones,
                                i + 1,
                              ).percentages,
                              innerFieldHeight: innerFieldHeight,
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
                      child: Container(
                        height: 23.0,
                        color: GlobalColors.secondary.withOpacity(0.4),
                        child: NormalTextSize(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          title: loadedMatch.awayTeamAbb,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // child: Column(
            //   children: [
            //     Center(
            //         child: Text('1st Half',
            //             style: Theme.of(context).textTheme.headline1)),
            //     Container(
            //       height: 500,
            //       width: double.infinity,
            //       decoration: BoxDecoration(
            //         image: DecorationImage(
            //           image: AssetImage("lib/resources/images/football_field.jpg"),
            //           fit: BoxFit.fill,
            //         ),
            //       ),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Padding(
            //             padding: EdgeInsets.only(left: 8.0),
            //             child: NormalTextSize(
            //               title: loadedMatch.homeTeam,
            //               color: Colors.white,
            //             ),
            //           ),
            //           Expanded(
            //             flex: 1,
            //             child: Container(
            //               height: 450,
            //               width: double.infinity,
            //               child: Stack(
            //                 children: [
            //                   ListView.builder(
            //                     physics: NeverScrollableScrollPhysics(),
            //                     itemBuilder: (ctx, i) => Container(
            //                       height: 450 / 2,
            //                       child: FieldZoneRow(
            //                         showPercentages: true,
            //                         zoneCount: 3,
            //                         percentages: getZonePercentages(
            //                           loadedMatch.firstHalfZones,
            //                           i + 1,
            //                         ).percentages,
            //                         innerFieldHeight: 450,
            //                       ),
            //                     ),
            //                     itemCount: 2,
            //                   ),
            //                   //Zone end ---
            //                 ],
            //               ),
            //             ),
            //           ),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.end,
            //             children: [
            //               Padding(
            //                 padding: EdgeInsets.only(right: 8.0),
            //                 child: NormalTextSize(
            //                   title: loadedMatch.awayTeam,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //     Center(
            //         child: Text('2nd Half',
            //             style: Theme.of(context).textTheme.headline1)),
            //     Container(
            //       height: 500,
            //       width: double.infinity,
            //       decoration: BoxDecoration(
            //         image: DecorationImage(
            //           image: AssetImage("lib/resources/images/football_field.jpg"),
            //           fit: BoxFit.fill,
            //         ),
            //       ),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Padding(
            //               padding: EdgeInsets.only(left: 8.0),
            //               child: NormalTextSize(
            //                 title: loadedMatch.homeTeam,
            //                 color: Colors.white,
            //               )),
            //           Expanded(
            //             flex: 1,
            //             child: Container(
            //               height: 450,
            //               width: double.infinity,
            //               child: Stack(
            //                 children: [
            //                   ListView.builder(
            //                     physics: NeverScrollableScrollPhysics(),
            //                     itemBuilder: (ctx, i) => Container(
            //                       height: 450 / 2,
            //                       child: FieldZoneRow(
            //                         showPercentages: true,
            //                         zoneCount: 3,
            //                         percentages: getZonePercentages(
            //                           loadedMatch.secondHalfZones,
            //                           i + 1,
            //                         ).percentages,
            //                         innerFieldHeight: 450,
            //                       ),
            //                     ),
            //                     itemCount: 2,
            //                   ),
            //                   //Zone end ---
            //                 ],
            //               ),
            //             ),
            //           ),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.end,
            //             children: [
            //               Padding(
            //                 padding: EdgeInsets.only(right: 8.0),
            //                 child: NormalTextSize(
            //                   title: loadedMatch.awayTeam,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ])));
  }
}

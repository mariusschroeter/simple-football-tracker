import 'package:flutter/material.dart';
import 'package:simple_football_tracker/models/zone.dart';
import 'package:simple_football_tracker/screens/add_match_start_match.screen.dart';
import 'package:simple_football_tracker/widgets/fieldzone.dart';
import 'package:simple_football_tracker/widgets/global_colors.dart';
import 'package:simple_football_tracker/widgets/scoreboard.dart';
import 'package:simple_football_tracker/widgets/stats_list.dart';
import 'package:simple_football_tracker/widgets/text_elements.dart';
import 'package:provider/provider.dart';

import '../providers/matches.dart';

class MatchDetailScreen extends StatefulWidget {
  static const routeName = "/match-detail";

  @override
  _MatchDetailScreenState createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _scoreboardRowKey = GlobalKey();
  final _bottomNavKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initField();
    });
  }

  double _screenHeight = 0;
  double _fieldHeight = 500;
  double _innerFieldHeight = 450;
  double _statusBarHeight = 0;

  _initField() {
    setState(() {
      _screenHeight = MediaQuery.of(context).size.height;
      _statusBarHeight = MediaQuery.of(context).padding.top;
      _fieldHeight = _screenHeight -
          _statusBarHeight -
          _scoreboardRowKey.currentContext.size.height -
          _bottomNavKey.currentContext.size.height;
      _innerFieldHeight = _fieldHeight - 46;
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

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final matchId = ModalRoute.of(context).settings.arguments as String;
    final loadedMatch =
        Provider.of<MatchesProvider>(context, listen: false).findById(matchId);

    final statsList = loadedMatch.stats.entries
        .map((e) => BarchartList(title: e.key, values: e.value))
        .toList();
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: _statusBarHeight),
            child: Row(
              key: _scoreboardRowKey,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
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
          ),
          _currentIndex == 0
              ? Stack(children: [
                  Container(
                    height: _fieldHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "lib/resources/images/football_field.jpg"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: _innerFieldHeight,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (ctx, i) => Container(
                                    height: _innerFieldHeight / 2,
                                    child: FieldZoneRow(
                                      showPercentages: true,
                                      zoneCount: 3,
                                      percentages: getZonePercentages(
                                        loadedMatch.totalZones,
                                        i + 1,
                                      ).percentages,
                                      innerFieldHeight: _innerFieldHeight,
                                    ),
                                  ),
                                  itemCount: 2,
                                ),
                                //Zone end ---
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 8.0,
                    child: Container(
                      color: GlobalColors.primary.withOpacity(0.4),
                      height: 23.0,
                      child: NormalTextSize(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        title: loadedMatch.homeTeamAbb.toUpperCase(),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 8,
                    child: Container(
                      color: GlobalColors.secondary.withOpacity(0.4),
                      height: 23.0,
                      child: NormalTextSize(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        title: loadedMatch.awayTeamAbb.toUpperCase(),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ])
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2.0),
                                  child: Text(
                                    i == 0
                                        ? '${statsList[i].title} (%)'
                                        : '${statsList[i].title}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                StatsList(
                                  stats: statsList[i].values,
                                  isHalfTime:
                                      // i == 0 ? _matchHalfTime : true,
                                      true,
                                ),
                              ],
                            ),
                          ),
                          itemCount: statsList.length,
                          shrinkWrap: true,
                        ),
                      ),
                    )
                  ],
                ),
        ],
      )),
      bottomNavigationBar: BottomNavigationBar(
        key: _bottomNavKey,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(.60),
        selectedFontSize: 15,
        unselectedFontSize: 14,
        onTap: (value) {
          setState(() => _currentIndex = value);
        },
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            label: 'Match',
            icon: Icon(Icons.sports_soccer),
          ),
          BottomNavigationBarItem(
            label: 'Stats',
            icon: Icon(Icons.data_usage),
          ),
        ],
      ),
    );
  }
}

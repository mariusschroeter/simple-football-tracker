import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:football_provider_app/screens/match_instructions_screen.dart';
import 'package:football_provider_app/providers/matches.dart';
import 'package:football_provider_app/widgets/app_drawer_in_match.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:football_provider_app/widgets/match_ball.dart';
import 'package:football_provider_app/widgets/match_goal.dart';
import 'package:football_provider_app/widgets/scoreboard.dart';
import 'package:football_provider_app/widgets/stats_list.dart';
import 'package:football_provider_app/models/zone.dart';
import 'package:football_provider_app/providers/match.dart';
import 'package:football_provider_app/widgets/fieldzone.dart';
import 'package:football_provider_app/widgets/text_elements.dart';

class AddMatchStartMatchScreen extends StatefulWidget {
  static const routeName = '/start-match';

  AddMatchStartMatchScreen({
    this.homeTeam,
    this.homeTeamAbb,
    this.awayTeam,
    this.awayTeamAbb,
    this.zoneLines = 2,
    this.zonesPerLine = 3,
  });

  final String homeTeam;
  final String homeTeamAbb;
  final String awayTeam;
  final String awayTeamAbb;

  final int zoneLines;
  final int zonesPerLine;

  @override
  _AddMatchStartMatchScreenState createState() =>
      _AddMatchStartMatchScreenState();
}

class _AddMatchStartMatchScreenState extends State<AddMatchStartMatchScreen> {
  final GlobalKey<ScaffoldState> _startMatchScaffoldKey =
      GlobalKey<ScaffoldState>();
  final _bottomNavKey = GlobalKey();
  final _scoreboardRowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionsOverlay(context);
      _initField();
      _buildZones();
      _buildMatch();
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  double _screenWidth = 0;
  double _screenHeight = 0;
  double _fieldHeight = 0;
  double _innerFieldHeight = 0;
  double _statusBarHeight = 0;

  _initField() {
    setState(() {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
      _statusBarHeight = MediaQuery.of(context).padding.top;
      _fieldHeight = _screenHeight -
          _statusBarHeight -
          _bottomNavKey.currentContext.size.height -
          _scoreboardRowKey.currentContext.size.height;
      _innerFieldHeight = _fieldHeight - 46;
    });
  }

  //Match Stats
  Match _match;

  void _buildMatch() {
    _match = Match(
      id: Uuid().v4(),
      dateTime: DateTime.now(),
      homeTeam: widget.homeTeam,
      homeTeamAbb: widget.homeTeamAbb,
      awayTeam: widget.awayTeam,
      awayTeamAbb: widget.awayTeamAbb,
      firstHalfZones: [],
      secondHalfZones: [],
      score: [],
      // matchOutcome: MatchOutcome.DRAW,
    );
  }

  //Field Ball
  Offset _ballPosition = Offset(0, 0);

  _onBallMovement(TapDownDetails details) {
    final x = details.localPosition.dx;
    final y = details.localPosition.dy;
    setState(() {
      _ballPosition = Offset(x - (26 / 2), y - (26 / 2));
    });
    _setZoneActive(x, y);
  }

  //Field Heatmap
  Color colorLow = Color.fromRGBO(82, 175, 80, 1);
  Color colorHigh = Color.fromRGBO(238, 70, 52, 1);

  //Feld Zonen
  List<Zone> zones = [];
  Zone _activeZone;
  bool _showPercentages = false;
  bool _showHeatMap = false;
  bool _showZones = false;

  _buildZones() {
    double fieldWidth = _screenWidth;
    //innerFieldHeight
    double fieldHeight = _innerFieldHeight;
    double zoneWidth = fieldWidth / widget.zonesPerLine;
    double zoneHeight = fieldHeight / widget.zoneLines;
    for (var i = 1; i < widget.zoneLines + 1; i++) {
      for (var ii = 1; ii < widget.zonesPerLine + 1; ii++) {
        double xStart = zoneWidth * (ii - 1);
        double yStart = zoneHeight * (i - 1);
        double xEnd = zoneWidth * ii;
        double yEnd = zoneHeight * i;
        zones.add(Zone(
            homePercentage: 0.0,
            awayPercentage: 0.0,
            xStart: xStart,
            yStart: yStart,
            xEnd: xEnd,
            yEnd: yEnd));
      }
    }
    _switchTeamBallPossession(isHome: true, isInit: true);
  }

  _setZoneActive(double x, double y) {
    final activeZoneCopy = _activeZone;
    _activeZone = zones.firstWhere((element) =>
        element.xStart < x &&
        element.xEnd > x &&
        element.yStart < y &&
        element.yEnd > y);
    if (_activeZone == null) _activeZone = activeZoneCopy;
  }

  ZoneStats _getZonePercentages(int line) {
    List<double> homePercentages = [];
    List<double> awayPercentages = [];
    List<Color> colors = [];
    int indexStart = ((line - 1) * widget.zonesPerLine);
    int indexEnd = (line * widget.zonesPerLine);
    for (var i = indexStart; i < indexEnd; i++) {
      if (!_matchStart || _homePossession == 0) {
        homePercentages.add(0.0);
        colors.add(Colors.green);
      } else {
        final percentage = (zones[i].homePercentage / _homePossession) * 100;
        homePercentages.add(percentage);
        colors.add(Colors.yellow);
      }
    }
    for (var i = indexStart; i < indexEnd; i++) {
      if (!_matchStart || _awayPossession == 0)
        awayPercentages.add(0.0);
      else {
        awayPercentages.add((zones[i].awayPercentage / _awayPossession) * 100);
      }
    }
    List<List<double>> percentages = [homePercentages, awayPercentages];
    ZoneStats stats = ZoneStats(percentages: percentages, colors: colors);
    return stats;
  }

  _getPercentage({bool isHome, bool isTotal = false}) {
    final possession = isHome ? _homePossession : _awayPossession;
    final totalTime = isTotal ? _totalTime : 0;
    final totalPossession = isHome && isTotal
        ? _totalHomePossession
        : !isHome && isTotal
            ? _totalAwayPossession
            : 0;
    return (((possession + totalPossession) / (_start + totalTime)) * 100);
  }

  _switchPercentages(bool showPercentages) {
    bool show = !_showPercentages;
    if (showPercentages != null) {
      show = showPercentages;
    }
    setState(() {
      _showPercentages = show;
    });
  }

  _switchHeatMap(bool showHeatMap) {
    bool show = !_showHeatMap;
    if (showHeatMap != null) {
      show = showHeatMap;
    }
    setState(() {
      _showHeatMap = show;
    });
  }

  _switchZones(bool showZones) {
    bool show = !_showZones;
    if (showZones != null) {
      show = showZones;
    }
    setState(() {
      _showZones = show;
    });
  }

  //Wer hat den Ball?
  int _homePossession = 0;
  int _totalHomePossession = 0;
  int _awayPossession = 0;
  int _totalAwayPossession = 0;
  bool _homeTeamBallPossession = true;

  _switchTeamBallPossession({bool isHome, isInit = false}) {
    var home = isHome;
    if (home == null && !isInit) {
      home = !_homeTeamBallPossession;
    } else {
      double x = _screenWidth / 2 - 5;
      double y = _innerFieldHeight / 2;
      if (home) {
        y -= 20;
      } else {
        y += 10;
      }

      TapDownDetails details = TapDownDetails(localPosition: Offset(x, y));
      _onBallMovement(details);
    }
    setState(() {
      _homeTeamBallPossession = home;
    });
  }

  //Match Timer
  //90 min
  Timer _timer;
  int _start = 0;
  int _totalTime = 0;
  bool _matchStart = false;
  bool _matchPause = false;
  bool _matchHalfTime = false;

  _startTimer(int timerDuration) {
    setState(() {
      _start = timerDuration;
    });
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start > 5 && !_isExtraTime) {
            _pauseTimer();
            showAlertDialog(context);
          } else {
            _start++;

            if (_isExtraTime) _extraTime++;

            //Wer ist am Ball?
            if (_homeTeamBallPossession) {
              _homePossession++;
              _activeZone.homePercentage++;
            } else {
              _awayPossession++;
              _activeZone.awayPercentage++;
            }

            //stats updaten
            _updateStatsMap();

            //Match starten
            _isPossessionQuestion = false;
            _matchStart = true;
            _matchPause = false;

            //show Zones
            _switchZones(true);
          }
        },
      ),
    );
  }

  _pauseTimer() {
    _timer.cancel();
    setState(() {
      _matchPause = true;
    });
  }

  _endTimer() {
    _timer.cancel();
    List<ZonePercentages> zonePercentages = [];
    zonePercentages = zones
        .map(
          (e) => new ZonePercentages(
            homePercentage: e.homePercentage != 0.0
                ? ((e.homePercentage / _homePossession) * 100)
                : 0.0,
            awayPercentage: e.awayPercentage != 0.0
                ? ((e.awayPercentage / _awayPossession) * 100)
                : 0.0,
          ),
        )
        .toList();
    setState(() {
      _matchStart = false;
      _matchPause = false;
      _isExtraTime = false;
      _extraTime = 0;
      _totalTime = _start;
      _start = 0;
      _totalHomePossession = _homePossession;
      _homePossession = 0;
      _totalAwayPossession = _awayPossession;
      _awayPossession = 0;
      if (!_matchHalfTime) {
        _match.firstHalfZones = zonePercentages;
        _matchHalfTime = true;
      } else {
        _match.secondHalfZones = zonePercentages;
        _setMatchOutcome();
        _endMatch();
      }
      zones.forEach((element) {
        element.homePercentage = 0.0;
        element.awayPercentage = 0.0;
      });
      _isPossessionQuestion = true;
    });
    _switchHeatMap(false);
    _switchPercentages(false);
    _switchTeamBallPossession(isHome: true, isInit: true);
  }

  _setMatchOutcome() {
    setState(() {
      _match.score = [_homeTeamGoals, _awayTeamGoals];
    });
  }

  _endMatch() {
    Provider.of<MatchesProvider>(context, listen: false)
        .addMatch(_match)
        .then((value) =>
            Navigator.of(context).pop('Match added! Pull to refresh.'))
        .catchError((error) {
      print(error);
      //Navigator.of(context).pop('An error occurred!');
    });
  }

  unpauseTimer() => _startTimer(_start);

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(90));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  //Nachspielzeit Timer
  bool _isExtraTime = false;
  int _extraTime = 0;

  _startExtraTime() {
    setState(() {
      _isExtraTime = true;
    });
    unpauseTimer();
  }

  //Who has the ball at start?
  bool _isPossessionQuestion = true;

  //Goal and Shot tracking
  int _homeTeamGoals = 0;
  int _homeTeamShotsOnTarget = 0;
  int _homeTeamShotsOffTarget = 0;
  int _homeTeamCornerKicks = 0;

  int _awayTeamGoals = 0;
  int _awayTeamShotsOnTarget = 0;
  int _awayTeamShotsOffTarget = 0;
  int _awayTeamCornerKicks = 0;

  _checkShot(isHome) {
    showAlertDialog(context, goalCheck: true, isHomeShot: isHome);
  }

  _onShot({isHomeShot, isGoal = false, isSaved = false, isPast = false}) {
    if (isHomeShot) {
      setState(() {
        if (isGoal) {
          _homeTeamGoals++;
          _homeTeamShotsOnTarget++;
          _switchTeamBallPossession(isHome: false, isInit: true);
        } else if (isSaved) {
          _homeTeamShotsOnTarget++;
          TapDownDetails details = TapDownDetails(
              localPosition: Offset(_screenWidth / 2, _innerFieldHeight - 20));
          _onBallMovement(details);
          _switchTeamBallPossession();
        } else if (isPast) {
          _homeTeamShotsOffTarget++;
          TapDownDetails details = TapDownDetails(
              localPosition: Offset(_screenWidth / 2, _innerFieldHeight - 20));
          _onBallMovement(details);
          _switchTeamBallPossession();
        } else {
          _homeTeamShotsOnTarget++;
          _homeTeamCornerKicks++;
          TapDownDetails details;
          if (_ballPosition.dx < (_screenWidth / 2)) {
            details = TapDownDetails(
                localPosition: Offset(10, _innerFieldHeight - 20));
          } else {
            details = TapDownDetails(
                localPosition:
                    Offset(_screenWidth - 20, _innerFieldHeight - 20));
          }
          _onBallMovement(details);
        }
      });
    } else {
      setState(() {
        if (isGoal) {
          _awayTeamGoals++;
          _awayTeamShotsOnTarget++;
          _switchTeamBallPossession(isHome: true, isInit: true);
        } else if (isSaved) {
          _awayTeamShotsOnTarget++;
          TapDownDetails details =
              TapDownDetails(localPosition: Offset(_screenWidth / 2, 20));
          _onBallMovement(details);
          _switchTeamBallPossession();
        } else if (isPast) {
          _awayTeamShotsOffTarget++;
          TapDownDetails details =
              TapDownDetails(localPosition: Offset(_screenWidth / 2, 20));
          _onBallMovement(details);
          _switchTeamBallPossession();
        } else {
          _awayTeamShotsOnTarget++;
          _awayTeamCornerKicks++;
          TapDownDetails details;
          if (_ballPosition.dx < (_screenWidth / 2)) {
            details = TapDownDetails(localPosition: Offset(10, 0));
          } else {
            details =
                TapDownDetails(localPosition: Offset(_screenWidth - 20, 0));
          }
          _onBallMovement(details);
        }
      });
    }
    _updateStatsMap();
  }

  _updateStatsMap() {
    setState(() {
      _statsMap = {
        'Possession': {
          'Total': [
            _getPercentage(isHome: true, isTotal: true),
            _getPercentage(isHome: false, isTotal: true),
          ],
          // 'First Half': [
          //   _getPercentage(isHome: true, isTotal: false),
          //   _getPercentage(isHome: false, isTotal: false),
          // ]
        },
        'Shots': {
          'On Target': [_homeTeamShotsOnTarget, _awayTeamShotsOnTarget],
          'Off Target': [_homeTeamShotsOffTarget, _awayTeamShotsOffTarget],
        },
        'Other': {
          'Corner Kicks': [_homeTeamCornerKicks, _awayTeamCornerKicks],
        }
      };
    });
  }

  Map<String, Map<String, List<num>>> _statsMap = {
    'Possession': {
      'Total': [0, 0],
      // 'First Half': [0, 0],
      // 'Second Half': [0,0],
    },
    'Shots': {
      'On Target': [0, 0],
      'Off Target': [0, 0],
    },
    'Other': {
      'Corner kicks': [0, 0],
      // 'Fouls': [0,0],
    }
  };

  // Color _goalColor = Colors.transparent;

  // _onWillAcceptShot(bool isHomeShot) {
  //   Color goalColor = Colors.transparent;
  //   if (isHomeShot)
  //     goalColor = GlobalColors.primary;
  //   else
  //     goalColor = GlobalColors.secondary;

  //   _setGoalColor(goalColor);

  //   return true;
  // }

  // _setGoalColor(Color goalColor) {
  //   setState(() {
  //     _goalColor = goalColor;
  //   });
  // }

  //switch between tabs
  int _currentIndex = 0;

  //show Instructions
  _showInstructionsOverlay(BuildContext context) async {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
        builder: (context) => MatchInstructionsScreen(onClose: () {
              overlayEntry.remove();
            }));
    overlayState.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final time =
        _isExtraTime ? '45:00' : _printDuration(Duration(seconds: _start));
    final extraTime =
        _isExtraTime ? _printDuration(Duration(seconds: _extraTime)) : null;

    final statsList = _statsMap.entries
        .map((e) => BarchartList(title: e.key, values: e.value))
        .toList();

    return Scaffold(
      key: _startMatchScaffoldKey,
      drawer: AppDrawerInMatch(
        switchZones: _switchZones,
        switchHeatMap: _switchHeatMap,
        switchPercentages: _switchPercentages,
        zones: _showZones,
        heatmap: _showHeatMap,
        percentages: _showPercentages,
        showInstructions: _showInstructionsOverlay,
      ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: _statusBarHeight),
              child: Row(
                key: _scoreboardRowKey,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        _startMatchScaffoldKey.currentState.openDrawer();
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Scoreboard(
                      time: time,
                      extraTime: _extraTime != 0 ? extraTime : '',
                      homeTeam: widget.homeTeamAbb,
                      awayTeam: widget.awayTeamAbb,
                      homeGoals: _homeTeamGoals,
                      awayGoals: _awayTeamGoals,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      color: GlobalColors.secondary,
                      child: IconButton(
                        icon: _start == 0 && !_matchHalfTime
                            ? Icon(
                                Icons.play_arrow,
                              )
                            : _start == 0 && _matchHalfTime
                                ? Icon(
                                    Icons.play_arrow,
                                  )
                                : _matchPause
                                    ? Icon(Icons.repeat)
                                    : _isExtraTime && !_matchHalfTime
                                        ? Icon(Icons.stop)
                                        : _isExtraTime && _matchHalfTime
                                            ? Icon(Icons.stop)
                                            : Icon(Icons.pause),
                        onPressed: _start == 0
                            ? () => _startTimer(0)
                            : _matchPause
                                ? unpauseTimer
                                : _isExtraTime
                                    ? () => _endTimer()
                                    : _pauseTimer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: _fieldHeight,
              child: _currentIndex == 0
                  ? Stack(
                      children: [
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
                            children: [
                              MatchGoal(
                                onShot: _checkShot,
                                isHomeShot: false,
                                // onWillAcceptShot: _onWillAcceptShot,
                                // setGoalColor: _setGoalColor,
                                // color: _goalColor,
                              ),
                              GestureDetector(
                                onTapDown: (TapDownDetails details) =>
                                    _onBallMovement(details),
                                onDoubleTap: () => _switchTeamBallPossession(),
                                child: Container(
                                  color: Colors.transparent,
                                  height: _innerFieldHeight,
                                  width: double.infinity,
                                  child: Stack(
                                    children: [
                                      //Zone start ---
                                      _showPercentages ||
                                              _showHeatMap ||
                                              _showZones
                                          ? ListView.builder(
                                              padding: EdgeInsets.all(0),
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder: (ctx, i) =>
                                                  Container(
                                                height: _innerFieldHeight /
                                                    widget.zoneLines,
                                                child: FieldZoneRow(
                                                  innerFieldHeight:
                                                      _innerFieldHeight,
                                                  zoneCount: 3,
                                                  percentages:
                                                      _getZonePercentages(i + 1)
                                                          .percentages,
                                                  showPercentages:
                                                      _showPercentages,
                                                  showHeatMap: _showHeatMap,
                                                ),
                                              ),
                                              itemCount: widget.zoneLines,
                                            )
                                          : SizedBox(),
                                      //Zone end ---

                                      MatchBall(
                                        ballPosition: _ballPosition,
                                        color: _homeTeamBallPossession
                                            ? GlobalColors.primary
                                            : GlobalColors.secondary,
                                      ),
                                      Visibility(
                                        visible: _isPossessionQuestion,
                                        child: Column(
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  _switchTeamBallPossession(
                                                      isHome: true),
                                              child: Container(
                                                color: _homeTeamBallPossession
                                                    ? Colors.transparent
                                                    : Colors.grey
                                                        .withOpacity(0.5),
                                                width: double.infinity,
                                                height: _innerFieldHeight / 2,
                                                child: Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: GlobalColors
                                                            .primary
                                                            .withOpacity(
                                                                _homeTeamBallPossession
                                                                    ? 0.4
                                                                    : 0.2),
                                                        border: Border.all(
                                                            width: 0.1,
                                                            color:
                                                                Colors.white)),
                                                    child: NormalTextSize(
                                                      size: 30,
                                                      title:
                                                          '${widget.homeTeamAbb.toUpperCase()}',
                                                      color: Colors.white,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 8.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () =>
                                                  _switchTeamBallPossession(
                                                      isHome: false),
                                              child: Container(
                                                color: !_homeTeamBallPossession
                                                    ? Colors.transparent
                                                    : Colors.grey
                                                        .withOpacity(0.5),
                                                width: double.infinity,
                                                height: _innerFieldHeight / 2,
                                                child: Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: GlobalColors
                                                            .secondary
                                                            .withOpacity(
                                                                !_homeTeamBallPossession
                                                                    ? 0.3
                                                                    : 0.1),
                                                        border: Border.all(
                                                            width: 0.1,
                                                            color:
                                                                Colors.white)),
                                                    child: NormalTextSize(
                                                      size: 30,
                                                      title:
                                                          '${widget.awayTeamAbb.toUpperCase()}',
                                                      color: Colors.white,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 8.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              MatchGoal(
                                onShot: _checkShot,
                                isHomeShot: true,
                                // onWillAcceptShot: _onWillAcceptShot,
                                // setGoalColor: _setGoalColor,
                                // color: _goalColor,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 8.0,
                          child: Container(
                            height: 23.0,
                            color: GlobalColors.primary.withOpacity(0.4),
                            child: NormalTextSize(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              title: widget.homeTeamAbb.toUpperCase(),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 8,
                          child: Container(
                            height: 23.0,
                            color: GlobalColors.secondary.withOpacity(0.4),
                            child: NormalTextSize(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              title: widget.awayTeamAbb.toUpperCase(),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
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
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context,
      {bool goalCheck = false, bool isHomeShot}) {
    Widget itsNotHalftimeButton = FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _startExtraTime();
      },
    );
    Widget itsHalftimeButton = FlatButton(
      child: Text("Yes"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _endTimer();
      },
    );

    Widget pastGoal = FlatButton(
      child: Text("Past the target"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _onShot(isGoal: false, isHomeShot: isHomeShot, isPast: true);
      },
    );
    Widget savedAndCorner = FlatButton(
      child: Text("Saved/Blocked and corner"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _onShot(isGoal: false, isHomeShot: isHomeShot);
      },
    );
    Widget saved = FlatButton(
      child: Text("Saved"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _onShot(isGoal: false, isHomeShot: isHomeShot, isSaved: true);
      },
    );
    Widget goalButton = FlatButton(
      child: Text(
        "Goal!",
        style: TextStyle(color: Colors.white),
      ),
      color: GlobalColors.primary.withOpacity(0.4),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _onShot(isGoal: true, isHomeShot: isHomeShot);
      },
    );

    final title = goalCheck
        ? "Goal Check"
        : _matchHalfTime
            ? "Match End"
            : "Halftime";
    final subtitle = goalCheck
        ? "What is the result of this shot?"
        : _matchHalfTime
            ? "Has the match ended yet?"
            : "Is it Halftime yet?";

    final actions = goalCheck
        ? [pastGoal, saved, savedAndCorner, goalButton]
        : [itsNotHalftimeButton, itsHalftimeButton];

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(subtitle),
          actions: actions,
        );
      },
    );
  }
}

class BarchartList {
  String title;
  Map<String, List<num>> values;

  BarchartList({this.title, this.values});
}

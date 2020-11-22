import 'dart:async';

import 'package:flutter/material.dart';
import 'package:football_provider_app/providers/matches.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:football_provider_app/models/zone.dart';
import 'package:football_provider_app/providers/match.dart';
import 'package:football_provider_app/widgets/fieldzone.dart';
import 'package:football_provider_app/widgets/text_elements.dart';

class AddMatchStartMatchScreen extends StatefulWidget {
  AddMatchStartMatchScreen({
    this.homeTeam,
    this.awayTeam,
    this.zoneLines = 2,
    this.zonesPerLine = 3,
  });

  final String homeTeam;
  final String awayTeam;

  final int zoneLines;
  final int zonesPerLine;

  @override
  _AddMatchStartMatchScreenState createState() =>
      _AddMatchStartMatchScreenState();
}

class _AddMatchStartMatchScreenState extends State<AddMatchStartMatchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildZones();
      _buildMatch();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  //other
  bool _showSettings = false;

  //Match Stats
  Match _match;

  void _buildMatch() {
    _match = Match(
      id: Uuid().v4(),
      dateTime: DateTime.now(),
      homeTeam: widget.homeTeam,
      awayTeam: widget.awayTeam,
      firstHalfZones: [],
      secondHalfZones: [],
    );
  }

  //Field Ball
  Offset _ballPosition;

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

  _buildZones() {
    double fieldWidth = MediaQuery.of(context).size.width;
    double fieldHeight = 450;
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

  _switchPercentages() {
    setState(() {
      _showPercentages = !_showPercentages;
    });
  }

  _switchHeatMap() {
    setState(() {
      _showHeatMap = !_showHeatMap;
    });
  }

  setPercentagesPerZone(int minute) {
    List<ZonePercentages> zonePercentages = [];
    zonePercentages = zones
        .map((e) => new ZonePercentages(
              homePercentage: e.homePercentage != 0.0
                  ? ((e.homePercentage / _homePossession) * 100)
                  : 0.0,
              awayPercentage: e.awayPercentage != 0.0
                  ? ((e.awayPercentage / _awayPossession) * 100)
                  : 0.0,
            ))
        .toList();
  }

  //Wer hat den Ball?
  int _homePossession = 0;
  int _totalHomePossession = 0;
  int _awayPossession = 0;
  int _totalAwayPossession = 0;
  bool _homeTeamBallPossession = true;

  _switchTeamBallPossession() {
    setState(() {
      _homeTeamBallPossession = !_homeTeamBallPossession;
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
            _start = _start + 1;

            if (_isExtraTime) _extraTime = _extraTime + 1;

            //Wer ist am Ball?
            if (_homeTeamBallPossession) {
              _homePossession = _homePossession + 1;
              _activeZone.homePercentage = _activeZone.homePercentage + 1;
            } else {
              _awayPossession = _awayPossession + 1;
              _activeZone.awayPercentage = _activeZone.awayPercentage + 1;
            }

            //Match starten
            _matchStart = true;
            _matchPause = false;
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
        _endMatch();
      }
      zones.forEach((element) {
        element.homePercentage = 0.0;
        element.awayPercentage = 0.0;
      });
      _isPossessionQuestion = true;
    });
  }

  _endMatch() {
    Provider.of<MatchesProvider>(context, listen: false).addMatch(_match);
    Navigator.of(context).pop();
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

  void startExtraTime() {
    setState(() {
      _isExtraTime = true;
    });
    unpauseTimer();
  }

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget itsNotHalftimeButton = FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        startExtraTime();
      },
    );
    Widget itsHalftimeButton = FlatButton(
      child: Text("Yes"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        _endTimer();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(_matchHalfTime ? "Match End" : "Halftime"),
      content: Text(
          _matchHalfTime ? "Has the match ended yet?" : "Is it Halftime yet?"),
      actions: [
        itsNotHalftimeButton,
        itsHalftimeButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  //

  //Allow switch of sides
  //bool _homeTopOfField = true;

  // _switchSides() {
  //   if (!_matchStart) {
  //     setState(() {
  //       _homeTopOfField = !_homeTopOfField;
  //     });
  //   }
  // }

  //Who has the ball at start?
  bool _isPossessionQuestion = true;

  void _setPossessionAtMatchStart(bool isHome) {
    double x = MediaQuery.of(context).size.width / 2;
    double y = 450 / 2;
    if (isHome) {
      y -= 20;
    } else {
      y += 20;
    }

    TapDownDetails details = TapDownDetails(localPosition: Offset(x, y));
    _onBallMovement(details);

    setState(() {
      _homeTeamBallPossession = isHome;
      _isPossessionQuestion = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    final String homeTeam = widget.homeTeam.length > 15
        ? widget.homeTeam.substring(0, 15)
        : widget.homeTeam;
    final String awayTeam = widget.awayTeam.length > 15
        ? widget.awayTeam.substring(0, 15)
        : widget.awayTeam;
    final time =
        _isExtraTime ? '45:00' : _printDuration(Duration(seconds: _start));
    final extraTime =
        _isExtraTime ? _printDuration(Duration(seconds: _extraTime)) : null;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Column(
            children: [
              Container(
                  height: 500,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage("lib/resources/images/football_field.jpg"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Padding(
                      //     padding: EdgeInsets.only(left: 8.0),
                      //     child:
                      //         //?
                      //         NormalTextSize(
                      //       title: homeTeam,
                      //       color: Colors.white,
                      //     )
                      //     // : NormalTextSize(
                      //     //     title: awayTeam,
                      //     //   ),
                      //     ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTapDown: (TapDownDetails details) =>
                              _onBallMovement(details),
                          onDoubleTap: () => _switchTeamBallPossession(),
                          child: Container(
                            color: Colors.transparent,
                            height: 450,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                //Zone start ---
                                _showPercentages || _showHeatMap
                                    ? ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (ctx, i) => Container(
                                          height: 450 / widget.zoneLines,
                                          child: FieldZoneRow(
                                            zoneCount: 3,
                                            percentages:
                                                _getZonePercentages(i + 1)
                                                    .percentages,
                                            showPercentages: _showPercentages,
                                            showHeatMap: _showHeatMap,
                                          ),
                                        ),
                                        itemCount: widget.zoneLines,
                                      )
                                    : SizedBox(),
                                //Zone end ---
                                //show total possession --
                                _showPercentages
                                    ? Positioned(
                                        top: 200,
                                        left: _matchHalfTime
                                            ? (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3) /
                                                2
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Text('HZ'),
                                                FieldZone(
                                                  showPercentages:
                                                      _showPercentages,
                                                  homePercentage:
                                                      _homePossession != 0
                                                          ? ((_homePossession /
                                                                  _start) *
                                                              100)
                                                          : 0.0,
                                                  awayPercentage:
                                                      _awayPossession != 0
                                                          ? ((_awayPossession /
                                                                  _start) *
                                                              100)
                                                          : 0.0,
                                                  isTotalZone: true,
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                              visible: _matchHalfTime,
                                              child: Column(
                                                children: [
                                                  Text('TOTAL'),
                                                  FieldZone(
                                                    showPercentages:
                                                        _showPercentages,
                                                    homePercentage:
                                                        (((_homePossession +
                                                                    _totalHomePossession) /
                                                                (_start +
                                                                    _totalTime)) *
                                                            100),
                                                    awayPercentage:
                                                        (((_awayPossession +
                                                                    _totalAwayPossession) /
                                                                (_start +
                                                                    _totalTime)) *
                                                            100),
                                                    isTotalZone: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                                //end total possession--
                                Positioned(
                                  top: _ballPosition != null
                                      ? _ballPosition.dy
                                      : 450 / 2,
                                  left: _ballPosition != null
                                      ? _ballPosition.dx
                                      : MediaQuery.of(context).size.width / 2,
                                  child: Draggable(
                                    // onDraggableCanceled:
                                    //     (Velocity velocity, Offset offset) {
                                    //   _onDrag(offset);
                                    //   // _updateHeatMap();
                                    // },
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      color: Colors.transparent,
                                      child: Icon(
                                        Icons.sports_soccer,
                                        color: _homeTeamBallPossession
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    feedback: Icon(Icons.sports_soccer),
                                    childWhenDragging: Icon(
                                      Icons.sports_soccer,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _isPossessionQuestion,
                                  child: Container(
                                    height: 500,
                                    width: double.infinity,
                                    color: Colors.grey,
                                    child: Column(
                                      children: [
                                        NormalTextSize(
                                          title: 'Who has the ball?',
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              InkWell(
                                                onTap: () =>
                                                    _setPossessionAtMatchStart(
                                                        true),
                                                child: Container(
                                                  height: 100,
                                                  child: NormalTextSize(
                                                    title: 'Home',
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () =>
                                                    _setPossessionAtMatchStart(
                                                        false),
                                                child: Container(
                                                  height: 100,
                                                  child: NormalTextSize(
                                                    title: 'Away',
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
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child:
                                  // ?
                                  NormalTextSize(
                                title: awayTeam,
                              )
                              // : NormalTextSize(
                              //     title: homeTeam,
                              //     color: Colors.white,
                              //   ),
                              ),
                        ],
                      ),
                    ],
                  )),
              //Timer Start ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      NormalTextSize(title: '$time'),
                      extraTime != null ? Text('+$extraTime') : SizedBox()
                    ],
                  ),
                  Column(
                    children: [
                      // RaisedButton(
                      //   color: Colors.grey,
                      //   onPressed: _switchSides,
                      //   child: Text('Switch Sides'),
                      // ),
                      RaisedButton(
                        color: Colors.grey,
                        onPressed: _start == 0
                            ? () => _startTimer(0)
                            : _matchPause
                                ? unpauseTimer
                                : _isExtraTime
                                    ? () => _endTimer()
                                    : _pauseTimer,
                        child: Text(
                          _start == 0 && !_matchHalfTime
                              ? 'Start Match'
                              : _start == 0 && _matchHalfTime
                                  ? 'Start 2nd Half'
                                  : _matchPause
                                      ? 'Resume Match'
                                      : _isExtraTime && !_matchHalfTime
                                          ? 'End Half'
                                          : _isExtraTime && _matchHalfTime
                                              ? 'End Match'
                                              : 'Pause Match',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              //Timer End ---
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: _showSettings,
            child: Column(
              children: [
                FloatingActionButton(
                  child: Icon(Icons.invert_colors),
                  onPressed: () {
                    _switchHeatMap();
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                FloatingActionButton(
                  child: Text(
                    "%",
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                    _switchPercentages();
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          FloatingActionButton(
            child: Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
    );
  }
}

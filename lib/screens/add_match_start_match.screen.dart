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
  Offset ballPosition;

  _onBallMovement(TapDownDetails details) {
    final x = details.localPosition.dx;
    final y = details.localPosition.dy;
    setState(() {
      ballPosition = Offset(x - (26 / 2), y - (26 / 2));
    });
    setZoneActive(x, y);
  }

  //Feld Zonen
  List<Zone> zones = [];
  Zone _activeZone;
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

  setZoneActive(double x, double y) {
    final activeZoneCopy = _activeZone;
    _activeZone = zones.firstWhere((element) =>
        element.xStart < x &&
        element.xEnd > x &&
        element.yStart < y &&
        element.yEnd > y);
    if (_activeZone == null) _activeZone = activeZoneCopy;
  }

  List<List<double>> getZonePercentages(int line) {
    List<double> homePercentages = [];
    List<double> awayPercentages = [];
    int indexStart = ((line - 1) * widget.zonesPerLine);
    int indexEnd = (line * widget.zonesPerLine);
    for (var i = indexStart; i < indexEnd; i++) {
      if (!_matchStart || _homePossession == 0)
        homePercentages.add(0.0);
      else {
        homePercentages.add((zones[i].homePercentage / _homePossession) * 100);
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
    return percentages;
  }

  switchHeatMap() {
    setState(() {
      _showHeatMap = !_showHeatMap;
    });
  }

  setPercentagesPerZone(int minute) {
    List<ZonePercentages> zonePercentages = [];
    zonePercentages = zones
        .map((e) => new ZonePercentages(
              minute: minute,
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

  void switchTeamBallPossession() {
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

  void startTimer(int timerDuration) {
    setState(() {
      _start = timerDuration;
    });
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start > 5 && !_isExtraTime) {
            pauseTimer();
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

  void pauseTimer() {
    _timer.cancel();
    setState(() {
      _matchPause = true;
    });
  }

  void endTimer() {
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
        endMatch();
      }
      zones.forEach((element) {
        element.homePercentage = 0.0;
        element.awayPercentage = 0.0;
      });
      _isPossessionQuestion = true;
    });
  }

  void endMatch() {
    Provider.of<MatchesProvider>(context, listen: false)
        .addMatchOffline(_match);
    Navigator.of(context).pop();
  }

  void unpauseTimer() => startTimer(_start);

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
        endTimer();
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
                      Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child:
                              //?
                              NormalTextSize(
                            title: homeTeam,
                            color: Colors.white,
                          )
                          // : NormalTextSize(
                          //     title: awayTeam,
                          //   ),
                          ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTapDown: (TapDownDetails details) =>
                              _onBallMovement(details),
                          onDoubleTap: () => switchTeamBallPossession(),
                          child: Container(
                            color: Colors.transparent,
                            height: 450,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                //Zone start ---
                                _showHeatMap
                                    ? ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (ctx, i) => Container(
                                          height: 450 / widget.zoneLines,
                                          child: FieldZoneRow(
                                            zoneCount: 3,
                                            percentages:
                                                getZonePercentages(i + 1),
                                          ),
                                        ),
                                        itemCount: widget.zoneLines,
                                      )
                                    : SizedBox(),
                                //Zone end ---
                                //show total possession --
                                _showHeatMap
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
                                  top: ballPosition != null
                                      ? ballPosition.dy
                                      : 450 / 2,
                                  left: ballPosition != null
                                      ? ballPosition.dx
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
                            ? () => startTimer(0)
                            : _matchPause
                                ? unpauseTimer
                                : _isExtraTime
                                    ? () => endTimer()
                                    : pauseTimer,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switchHeatMap();
        },
      ),
    );
  }
}

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
  int _awayPossession = 0;
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
          if (_start > 5 && !_matchExtraTime) {
            timer.cancel();
            showAlertDialog(context);
          } else {
            _start = _start + 1;
            if (_activeZone == null) {
              setZoneActive(10, 10);
            }
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
      _start = 0;
      _homePossession = 0;
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
  bool _matchExtraTime = false;

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget itsNotHalftimeButton = FlatButton(
      child: Text("No"),
      onPressed: () {},
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
      title: Text("Halftime?"),
      content: Text("Is it Halftime yet?"),
      actions: [
        // itsNotHalftimeButton,
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
        _matchExtraTime ? '45:00' : _printDuration(Duration(seconds: _start));
    final extraTime =
        _matchExtraTime ? _printDuration(Duration(seconds: _start)) : null;
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
                                Positioned(
                                  top: ballPosition != null
                                      ? ballPosition.dy
                                      : MediaQuery.of(context).size.height / 2,
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
                                : _matchExtraTime
                                    ? () => endTimer()
                                    : pauseTimer,
                        child: Text(
                          _start == 0 && !_matchHalfTime
                              ? 'Start Match'
                              : _start == 0 && _matchHalfTime
                                  ? 'Start 2nd Half'
                                  : _matchPause
                                      ? 'Resume Match'
                                      : _matchExtraTime && !_matchHalfTime
                                          ? 'End Half'
                                          : _matchExtraTime && _matchHalfTime
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

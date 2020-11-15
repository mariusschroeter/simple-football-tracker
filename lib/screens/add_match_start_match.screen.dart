import 'dart:async';

import 'package:flutter/material.dart';
import 'package:football_provider_app/models/zone.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildZones());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  //Field props
  //final GlobalKey _footballField = GlobalKey();
  // Size footballFieldSize;

  // getFieldSize() {
  //   RenderBox _footballFieldBox =
  //       _footballField.currentContext.findRenderObject();
  //   footballFieldSize = _footballFieldBox.size;
  //   setState(() {});
  // }

  //Field Ball

  Offset ballPosition;

  _onBallMovement(TapDownDetails details) {
    final xNew = details.localPosition.dx;
    final yNew = details.localPosition.dy;
    setState(() {
      ballPosition = Offset(xNew - (26 / 2), yNew - (26 / 2));
    });
    //update active zone
  }

  //Feld Zonen

  _buildZones() {
    double fieldWidth = MediaQuery.of(context).size.width;
    double fieldHeight = 500;
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

  List<Zone> zones = [];

  Zone _activeZone;

  setZoneActive(int line, int column) {
    if (line == 1 && column == 0)
      _activeZone = zones[0];
    else {
      int index = ((line - 1) * widget.zonesPerLine) + column;
      _activeZone = zones[index];
    }
  }

  List<List<double>> getZonePercentages(int line) {
    List<double> homePercentages = [];
    List<double> awayPercentages = [];
    int indexStart = ((line - 1) * widget.zonesPerLine);
    int indexEnd = (line * widget.zonesPerLine);
    for (var i = indexStart; i < indexEnd; i++) {
      if (!_matchStart)
        homePercentages.add(0.0);
      else {
        homePercentages.add((zones[i].homePercentage / _start) * 100);
      }
    }
    for (var i = indexStart; i < indexEnd; i++) {
      if (!_matchStart)
        awayPercentages.add(0.0);
      else {
        awayPercentages.add((zones[i].awayPercentage / _start) * 100);
      }
    }
    List<List<double>> percentages = [homePercentages, awayPercentages];
    return percentages;
  }

  //Wer hat den Ball?
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

  void startTimer(int timerDuration) {
    setState(() {
      _start = timerDuration;
    });
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start > 19 && !_matchExtraTime) {
            timer.cancel();
            showAlertDialog(context);
          } else {
            _start = _start + 1;
            if (_activeZone == null) {
              setZoneActive(1, 1);
            }
            //Wer ist am Ball?
            _homeTeamBallPossession
                ? _activeZone.homePercentage = _activeZone.homePercentage + 1
                : _activeZone.awayPercentage = _activeZone.awayPercentage + 1;

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
    setState(() {
      _matchStart = false;
      _matchPause = false;
    });
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
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        //implement extra time
        // _matchExtraTime = true;
        // startTimer(0);
        //for now just pop.
        endTimer();
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
      title: Text("Halftime?"),
      content: Text("Is it Halftime yet?"),
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

  //Show Home and Away Text
  bool _homeTopOfField = true;

  _switchSides() {
    setState(() {
      _homeTopOfField = !_homeTopOfField;
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
        _matchExtraTime ? '45:00' : _printDuration(Duration(seconds: _start));
    final extraTime =
        _matchExtraTime ? _printDuration(Duration(seconds: _start)) : null;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Column(
            children: [
              GestureDetector(
                onTapDown: (TapDownDetails details) => _onBallMovement(details),
                child: Container(
                  height: 500,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage("lib/resources/images/football_field.jpg"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: _homeTopOfField
                            ? NormalTextSize(
                                title: homeTeam,
                                color: Colors.white,
                              )
                            : NormalTextSize(
                                title: awayTeam,
                              ),
                      ),
                      Positioned(
                        top: ballPosition != null ? ballPosition.dy : 0,
                        left: ballPosition != null ? ballPosition.dx : 0,
                        child: GestureDetector(
                          onDoubleTap: () {
                            switchTeamBallPossession();
                          },
                          child: Draggable(
                            // onDraggableCanceled:
                            //     (Velocity velocity, Offset offset) {
                            //   _onDrag(offset);
                            //   // _updateHeatMap();
                            // },
                            child: Icon(Icons.sports_soccer,
                                color: _homeTeamBallPossession
                                    ? Colors.white
                                    : Colors.black),
                            feedback: Icon(Icons.sports_soccer),
                            childWhenDragging: Icon(Icons.sports_soccer),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: _homeTopOfField
                              ? NormalTextSize(
                                  title: awayTeam,
                                )
                              : NormalTextSize(
                                  title: homeTeam,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      //Zone start ---
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, i) => Container(
                          height: 450 / widget.zoneLines,
                          child: FieldZoneRow(
                            setZoneActive: setZoneActive,
                            line: i + 1,
                            zoneCount: 3,
                            percentages: getZonePercentages(i + 1),
                          ),
                        ),
                        itemCount: widget.zoneLines,
                      ),
                      //Zone end ---
                    ],
                  ),
                ),
              ),
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
                      RaisedButton(
                        color: Colors.grey,
                        onPressed: _switchSides,
                        child: Text('Switch Sides'),
                      ),
                      RaisedButton(
                        color: Colors.grey,
                        onPressed: _start == 0
                            ? () => startTimer(0)
                            : _matchPause
                                ? unpauseTimer
                                : _matchExtraTime
                                    ? endTimer
                                    : pauseTimer,
                        child: Text(_start == 0
                            ? 'Start Match'
                            : _matchPause
                                ? 'Resume Match'
                                : _matchExtraTime
                                    ? 'End Half'
                                    : 'Pause Match'),
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
          Navigator.pop(context, [widget.homeTeam, widget.awayTeam]);
        },
      ),
    );
  }
}

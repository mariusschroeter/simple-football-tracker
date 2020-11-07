import 'dart:async';

import 'package:flutter/material.dart';

import 'package:football_provider_app/widgets/text_elements.dart';

class Zone {
  double homePercentage;

  Zone({this.homePercentage});
}

class AddMatchStartMatchScreen extends StatefulWidget {
  AddMatchStartMatchScreen({this.homeTeam, this.awayTeam, this.zonesCount = 3});

  final String homeTeam;
  final String awayTeam;

  final int zonesCount;

  @override
  _AddMatchStartMatchScreenState createState() =>
      _AddMatchStartMatchScreenState();
}

class _AddMatchStartMatchScreenState extends State<AddMatchStartMatchScreen> {
  @override
  void initState() {
    super.initState();
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

  //Feld Zonen
  List<Zone> zones = [
    Zone(homePercentage: 0),
    Zone(homePercentage: 0),
    Zone(homePercentage: 0),
    Zone(homePercentage: 0),
    Zone(homePercentage: 0),
    Zone(homePercentage: 0),
  ];

  Zone _activeZone;

  setZoneActive(int index) {
    _activeZone = zones[index];
  }

  //Wer hat den Ball?
  bool homeTeamBallPossession = true;

  //Match Timer
  //90 min
  Timer _timer;
  int _start = 0;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start > 179) {
            timer.cancel();
          } else {
            _start = _start + 1;
            if (_activeZone == null) {
              setZoneActive(1);
            }
            _activeZone.homePercentage = _activeZone.homePercentage + 1;
          }
        },
      ),
    );
  }

  void stopTimer() {
    _timer.cancel();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(90));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  //Nachspielzeit Timer
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
    double screenWidth = MediaQuery.of(context).size.width;
    final String homeTeam = widget.homeTeam.length > 15
        ? widget.homeTeam.substring(0, 15)
        : widget.homeTeam;
    final String awayTeam = widget.awayTeam.length > 15
        ? widget.awayTeam.substring(0, 15)
        : widget.awayTeam;
    final time = _printDuration(Duration(seconds: _start));
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
                    //Zonen
                    Column(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () => setZoneActive(0),
                              child: Stack(
                                children: [
                                  Container(
                                    color: _activeZone == zones[0]
                                        ? Colors.green[100]
                                        : Colors.transparent,
                                    height: 250,
                                    width: screenWidth / 3,
                                  ),
                                  Positioned.fill(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        NormalTextSize(
                                            color: Colors.white,
                                            title: _start != 0 &&
                                                    zones[0].homePercentage !=
                                                        0.0
                                                ? '${((zones[0].homePercentage / _start) * 100).toStringAsFixed(2)} %'
                                                : '0 %'),
                                        NormalTextSize(title: '10%'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => setZoneActive(1),
                              child: Container(
                                height: 250,
                                width: screenWidth / 3,
                              ),
                            ),
                            InkWell(
                              onTap: () => setZoneActive(2),
                              child: Container(
                                height: 250,
                                width: screenWidth / 3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => setZoneActive(3),
                              child: Container(
                                height: 250,
                                width: screenWidth / 3,
                              ),
                            ),
                            InkWell(
                              onTap: () => setZoneActive(4),
                              child: Container(
                                height: 250,
                                width: screenWidth / 3,
                              ),
                            ),
                            InkWell(
                              onTap: () => setZoneActive(5),
                              child: Container(
                                height: 250,
                                width: screenWidth / 3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NormalTextSize(title: '$time'),
                  Column(
                    children: [
                      RaisedButton(
                        color: Colors.grey,
                        onPressed: _switchSides,
                        child: Text('Switch Sides'),
                      ),
                      RaisedButton(
                        color: Colors.grey,
                        onPressed: _start == 0 ? startTimer : stopTimer,
                        child:
                            Text(_start == 0 ? 'Start Match' : 'Pause Match'),
                      ),
                    ],
                  ),
                ],
              ),
              //Dann Timer
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

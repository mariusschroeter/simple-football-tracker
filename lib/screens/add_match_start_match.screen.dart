import 'dart:async';

import 'package:flutter/material.dart';

import 'package:football_provider_app/widgets/text_elements.dart';

class Zone {
  double homePercentage;

  Zone({this.homePercentage});
}

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
    for (var i = 0; i < 6; i++) {
      zones.add(Zone(homePercentage: 0.0));
    }
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

  List<double> getZonePercentages(int line) {
    List<double> percentages = [];
    int indexStart = ((line - 1) * widget.zonesPerLine);
    int indexEnd = (line * widget.zonesPerLine);
    for (var i = indexStart; i < indexEnd; i++) {
      if (!_matchStart)
        percentages.add(0.0);
      else {
        percentages.add((zones[i].homePercentage / _start) * 100);
      }
    }
    return percentages;
  }

  //Wer hat den Ball?
  bool homeTeamBallPossession = true;

  //Match Timer
  //90 min
  Timer _timer;
  int _start = 0;
  bool _matchStart = false;

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
              setZoneActive(1, 1);
            }
            _activeZone.homePercentage = _activeZone.homePercentage + 1;
            _matchStart = true;
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
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) => Container(
                        height: 500 / widget.zoneLines,
                        child: ZoneRow(
                          setZoneActive: setZoneActive,
                          line: i + 1,
                          zoneCount: 3,
                          percentages: getZonePercentages(i + 1),
                        ),
                      ),
                      itemCount: widget.zoneLines,
                    ),
                  ],
                ),
              ),
              //Zone end
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

class ZoneRow extends StatelessWidget {
  const ZoneRow({
    @required this.setZoneActive,
    @required this.line,
    @required this.zoneCount,
    @required this.percentages,
  });

  final dynamic setZoneActive;
  final int line;
  final int zoneCount;
  final List<double> percentages;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, i) => FieldZone(
          setZoneActive: setZoneActive,
          line: line,
          column: i,
          percentage: percentages[i],
        ),
        itemCount: zoneCount,
      ),
    );
  }
}

class FieldZone extends StatelessWidget {
  const FieldZone({
    Key key,
    this.setZoneActive,
    this.line,
    this.column,
    this.percentage,
  }) : super(key: key);

  final dynamic setZoneActive;
  final int line;
  final int column;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () => setZoneActive(line, column),
      child: Stack(
        children: [
          Container(
            height: 250,
            width: screenWidth / 3,
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NormalTextSize(
                  color: Colors.white,
                  title: '${percentage.toStringAsFixed(2)}%',
                ),
                NormalTextSize(title: '10%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

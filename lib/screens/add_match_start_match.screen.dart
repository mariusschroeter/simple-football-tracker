import 'dart:async';

import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/svg.dart';
import 'package:football_provider_app/widgets/text_elements.dart';

class AddMatchStartMatchScreen extends StatefulWidget {
  AddMatchStartMatchScreen({this.homeTeam, this.awayTeam});

  final String homeTeam;
  final String awayTeam;

  @override
  _AddMatchStartMatchScreenState createState() =>
      _AddMatchStartMatchScreenState();
}

class Zone {
  double homePercentage;
  double awayPercentage;

  Zone({this.homePercentage, this.awayPercentage});
}

class _AddMatchStartMatchScreenState extends State<AddMatchStartMatchScreen> {
  //Feld Zonen
  List<Zone> zones = [
    Zone(homePercentage: 0, awayPercentage: 0),
    Zone(homePercentage: 0, awayPercentage: 0),
    Zone(homePercentage: 0, awayPercentage: 0),
    Zone(homePercentage: 0, awayPercentage: 0),
    Zone(homePercentage: 0, awayPercentage: 0),
    Zone(homePercentage: 0, awayPercentage: 0),
  ];

  //Match Timer
  //90 min

  //Nachspielzeit Timer
  //

  bool _homeTopOfField = true;

  _switchSides() {
    setState(() {
      _homeTopOfField = !_homeTopOfField;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Column(
            children: [
              _homeTopOfField
                  ? NormalTextSize(widget.homeTeam)
                  : NormalTextSize(widget.awayTeam),
              Container(
                height: 500,
                child: Stack(
                  children: [
                    Center(
                      child: Svg(
                        name: 'football_field',
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 21.0),
                          child: InkWell(
                            child: Container(
                                height: 250,
                                width: 50,
                                color: Colors.lightGreen),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _homeTopOfField
                  ? NormalTextSize(widget.awayTeam)
                  : NormalTextSize(widget.homeTeam),
              RaisedButton(
                color: Colors.grey,
                onPressed: _switchSides,
                child: Text('Switch Sides'),
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

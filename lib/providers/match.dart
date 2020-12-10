import 'package:flutter/material.dart';
import 'package:football_provider_app/models/zone.dart';

//Ist eigetnlich noch ein model weil keine daten geändert werden
class Match {
  final String id;
  final DateTime dateTime;
  //Du bekommst diesen Wert wenn das Objekt erstellt wird!
  final String homeTeam;
  final String homeTeamAbb;
  final String awayTeam;
  final String awayTeamAbb;
  List<ZonePercentages> firstHalfZones;
  List<ZonePercentages> secondHalfZones;
  List<int> score = [1, 0];
  bool isWon = true;

  Match({
    this.id,
    this.dateTime,
    @required this.homeTeam,
    @required this.homeTeamAbb,
    @required this.awayTeam,
    @required this.awayTeamAbb,
    this.firstHalfZones,
    this.secondHalfZones,
    this.score,
    this.isWon,
  });

  void homeScored() {
    score[0] += 1;
  }

  void awayScored() {
    score[1] += 1;
  }

  // void toggleFavoriteStatus() {
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  // }
}

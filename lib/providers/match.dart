import 'package:flutter/material.dart';
import 'package:football_provider_app/models/zone.dart';

//Ist eigetnlich noch ein model weil keine daten geändert werden
class Match {
  final String id;
  final DateTime dateTime;
  final String homeTeam;
  final String homeTeamAbb;
  final String awayTeam;
  final String awayTeamAbb;
  List<ZonePercentages> firstHalfZones;
  List<ZonePercentages> secondHalfZones;
  List<int> score;

  Match({
    this.id,
    this.dateTime,
    @required this.homeTeam,
    this.homeTeamAbb,
    @required this.awayTeam,
    this.awayTeamAbb,
    @required this.firstHalfZones,
    @required this.secondHalfZones,
    @required this.score,
  });

  // void toggleFavoriteStatus() {
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  // }
}

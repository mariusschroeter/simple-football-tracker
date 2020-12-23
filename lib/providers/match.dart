import 'package:flutter/material.dart';
import 'package:simple_football_tracker/models/zone.dart';

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
  List<ZonePercentages> totalZones;
  List<int> score;
  Map<String, Map<String, List<num>>> stats;

  Match({
    this.id,
    this.dateTime,
    @required this.homeTeam,
    this.homeTeamAbb,
    @required this.awayTeam,
    this.awayTeamAbb,
    @required this.totalZones,
    this.firstHalfZones,
    this.secondHalfZones,
    @required this.score,
    @required this.stats,
  });

  // void toggleFavoriteStatus() {
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  // }
}

import 'package:flutter/material.dart';
import 'package:simple_football_tracker/models/zone.dart';

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
  final String matchLength;

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
    this.matchLength,
  });

  // void toggleFavoriteStatus() {
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  // }
}

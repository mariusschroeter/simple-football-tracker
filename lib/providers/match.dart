import 'package:flutter/material.dart';

//Ist eigetnlich noch ein model weil keine daten geändert werden
class Match {
  final String id;
  final DateTime dateTime;
  //Du bekommst diesen Wert wenn das Objekt erstellt wird!
  final String homeTeam;
  final String awayTeam;
  List<int> score;
  bool isWon;

  Match({
    this.id,
    this.dateTime,
    @required this.homeTeam,
    @required this.awayTeam,
    this.score,
    this.isWon = false,
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

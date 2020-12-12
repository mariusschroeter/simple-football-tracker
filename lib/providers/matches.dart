import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:football_provider_app/models/http_exception.dart';
import 'package:football_provider_app/models/zone.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import './match.dart';

class MatchesProvider with ChangeNotifier {
  List<Match> _items = [
    // Match(
    //   id: "0",
    //   dateTime: DateTime.now(),
    //   homeTeam: "Fühlingen",
    //   awayTeam: "Schwarz-Weiss-Köln",
    //   isWon: true,
    // ),
    // Match(
    //   id: "1",
    //   dateTime: DateTime.now(),
    //   homeTeam: "Fühlingen",
    //   awayTeam: "Ditib-Chorweiler",
    //   isWon: false,
    // ),
  ];

  List<Match> get items {
    return [..._items].reversed.toList();
  }

  // List<Match> get wonItems {
  //   return _items
  //       .where((match) => match.matchOutcome == MatchOutcome.WON)
  //       .toList();
  // }

  Match findById(String id) {
    return _items.firstWhere((match) => match.id == id);
  }

  void addMatchOffline(Match match) {
    _items.add(match);
    notifyListeners();
  }

  Future<void> addMatch(Match match) async {
    const url = 'https://football-tracker-3e8cc.firebaseio.com/matches.json';
    try {
      Map<String, List<double>> firstHalf = Map<String, List<double>>();
      for (var i = 0; i < match.firstHalfZones.length; i++) {
        var zone = match.firstHalfZones[i];
        firstHalf.addAll({
          'zone${i + 1}': [zone.homePercentage, zone.awayPercentage]
        });
      }
      Map<String, List<double>> secondHalf = Map<String, List<double>>();
      for (var i = 0; i < match.secondHalfZones.length; i++) {
        var zone = match.secondHalfZones[i];
        secondHalf.addAll({
          'zone${i + 1}': [zone.homePercentage, zone.awayPercentage]
        });
      }
      await http.post(url,
          body: json.encode({
            'homeTeam': match.homeTeam,
            'homeTeamAbb': match.homeTeamAbb,
            'awayTeam': match.awayTeam,
            'awayTeamAbb': match.awayTeamAbb,
            'firstHalfPercentages': firstHalf,
            'secondHalfPercentages': secondHalf,
            'dateTime': match.dateTime.millisecondsSinceEpoch,
            'score': match.score,
            // 'isWon': true,
          }));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetMatches() async {
    const url = 'https://football-tracker-3e8cc.firebaseio.com/matches.json';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final List<Match> loadedMatches = [];
      extractedData.forEach((matchId, matchData) {
        final Map<String, dynamic> firstHalf =
            matchData['firstHalfPercentages'] as Map<String, dynamic>;
        final List<ZonePercentages> firstHalfZones = [];
        firstHalf.entries.forEach((element) {
          firstHalfZones.add(ZonePercentages(
              homePercentage: element.value[0],
              awayPercentage: element.value[1]));
        });
        final Map<String, dynamic> secondHalf =
            matchData['secondHalfPercentages'] as Map<String, dynamic>;
        final List<ZonePercentages> secondHalfZones = [];
        secondHalf.entries.forEach((element) {
          secondHalfZones.add(ZonePercentages(
              homePercentage: element.value[0],
              awayPercentage: element.value[1]));
        });
        final List<int> score = matchData["score"].cast<int>();
        loadedMatches.add(Match(
          id: matchId,
          homeTeam: matchData['homeTeam'],
          homeTeamAbb: matchData['homeTeamAbb'],
          awayTeam: matchData['awayTeam'],
          awayTeamAbb: matchData['awayTeamAbb'],
          score: score,
          dateTime: DateTime.fromMillisecondsSinceEpoch(matchData['dateTime']),
          firstHalfZones: firstHalfZones,
          secondHalfZones: secondHalfZones,
        ));
      });
      _items = loadedMatches;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  void deleteMatch(String matchId) async {
    final url =
        'https://football-tracker-3e8cc.firebaseio.com/matches/$matchId.json';
    var existingIndex = _items.indexWhere((element) => element.id == matchId);
    var matchToBeDeleted = _items[existingIndex];
    if (matchToBeDeleted != null) {
      _items.remove(matchToBeDeleted);
      notifyListeners();
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items.insert(existingIndex, matchToBeDeleted);
        notifyListeners();
        throw HttpException('Could not delete the Match!');
      }
      matchToBeDeleted = null;
    }
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_football_tracker/models/http_exception.dart';
import 'package:simple_football_tracker/models/zone.dart';
import 'package:http/http.dart' as http;

import './match.dart';

class MatchesProvider with ChangeNotifier {
  List<Match> _items = [];

  final String authToken;
  final String userId;

  MatchesProvider(this.authToken, this.userId, this._items);

  List<Match> get items {
    return [..._items].reversed.toList();
  }

  List<Match> get oldestItemsFirst {
    return [..._items];
  }

  Match findById(String id) {
    return _items.firstWhere((match) => match.id == id);
  }

  void addMatchOffline(Match match) {
    _items.add(match);
    notifyListeners();
  }

  Future<void> addMatch(Match match) async {
    final url =
        'https://football-tracker-3e8cc.firebaseio.com/matches.json?auth=$authToken';
    try {
      Map<String, List<double>> totalZones = Map<String, List<double>>();
      for (var i = 0; i < match.totalZones.length; i++) {
        var zone = match.totalZones[i];
        totalZones.addAll({
          'zone${i + 1}': [zone.homePercentage, zone.awayPercentage]
        });
      }
      // Map<String, List<double>> firstHalf = Map<String, List<double>>();
      // for (var i = 0; i < match.firstHalfZones.length; i++) {
      //   var zone = match.firstHalfZones[i];
      //   firstHalf.addAll({
      //     'zone${i + 1}': [zone.homePercentage, zone.awayPercentage]
      //   });
      // }
      // Map<String, List<double>> secondHalf = Map<String, List<double>>();
      // for (var i = 0; i < match.secondHalfZones.length; i++) {
      //   var zone = match.secondHalfZones[i];
      //   secondHalf.addAll({
      //     'zone${i + 1}': [zone.homePercentage, zone.awayPercentage]
      //   });
      // }

      await http.post(url,
          body: json.encode({
            'homeTeam': match.homeTeam,
            'homeTeamAbb': match.homeTeamAbb,
            'awayTeam': match.awayTeam,
            'awayTeamAbb': match.awayTeamAbb,
            'totalZones': totalZones,
            'dateTime': match.dateTime.millisecondsSinceEpoch,
            'score': match.score,
            'stats': match.stats,
            // 'firstHalfPercentages': firstHalf,
            // 'secondHalfPercentages': secondHalf,
            // 'isWon': true,
            'userId': userId,
          }));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetMatches() async {
    final url =
        'https://football-tracker-3e8cc.firebaseio.com/matches.json?auth=$authToken&orderBy="userId"&equalTo="$userId"';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final List<Match> loadedMatches = [];
      extractedData.forEach((matchId, matchData) {
        final Map<String, dynamic> totalPercentages =
            matchData['totalZones'] as Map<String, dynamic>;
        final List<ZonePercentages> totalZones = [];
        totalPercentages.entries.forEach((element) {
          totalZones.add(ZonePercentages(
              homePercentage: element.value[0],
              awayPercentage: element.value[1]));
        });
        // final Map<String, dynamic> firstHalf =
        //     matchData['firstHalfPercentages'] as Map<String, dynamic>;
        // final List<ZonePercentages> firstHalfZones = [];
        // firstHalf.entries.forEach((element) {
        //   firstHalfZones.add(ZonePercentages(
        //       homePercentage: element.value[0],
        //       awayPercentage: element.value[1]));
        // });
        // final Map<String, dynamic> secondHalf =
        //     matchData['secondHalfPercentages'] as Map<String, dynamic>;
        // final List<ZonePercentages> secondHalfZones = [];
        // secondHalf.entries.forEach((element) {
        //   secondHalfZones.add(ZonePercentages(
        //       homePercentage: element.value[0],
        //       awayPercentage: element.value[1]));
        // });

        Map<String, Map<String, List<num>>> statsMap = {};
        Map<String, Map<String, List<num>>> statsMapOrdered = {};

        //
        final Map<String, dynamic> stats =
            matchData['stats'] as Map<String, dynamic>;

        stats.forEach((key, value) {
          final valuee = Map<String, dynamic>.from(value);
          valuee.entries.forEach((element) {
            final valueee = List<num>.from(element.value);
            valuee.addAll({element.key: valueee});
          });
          final castedValuee = Map<String, List<num>>.from(valuee);
          statsMap.addAll({key: castedValuee});
        });

        statsMapOrdered['Possession'] = statsMap['Possession'];
        statsMapOrdered['Shots'] = statsMap['Shots'];
        statsMapOrdered['Other'] = statsMap['Other'];

        final List<int> score = matchData['score'].cast<int>();

        loadedMatches.add(Match(
          id: matchId,
          homeTeam: matchData['homeTeam'],
          homeTeamAbb: matchData['homeTeamAbb'],
          awayTeam: matchData['awayTeam'],
          awayTeamAbb: matchData['awayTeamAbb'],
          score: score,
          dateTime: DateTime.fromMillisecondsSinceEpoch(matchData['dateTime']),
          totalZones: totalZones,
          stats: statsMapOrdered,
          // firstHalfZones: [],
          // secondHalfZones: [],
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
        'https://football-tracker-3e8cc.firebaseio.com/matches/$matchId.json?auth=$authToken';
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

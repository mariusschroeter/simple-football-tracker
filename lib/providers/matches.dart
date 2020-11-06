import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './match.dart';
import '../models/http_exception.dart';

class MatchesProvider with ChangeNotifier {
  List<Match> _items = [
    Match(
      id: "0",
      dateTime: DateTime.now(),
      homeTeam: "Fühlingen",
      awayTeam: "Schwarz-Weiss-Köln",
      isWon: true,
    ),
    Match(
      id: "1",
      dateTime: DateTime.now(),
      homeTeam: "Fühlingen",
      awayTeam: "Ditib-Chorweiler",
      isWon: false,
    ),
  ];

  List<Match> get items {
    return [..._items].reversed.toList();
  }

  List<Match> get wonItems {
    return _items.where((match) => match.isWon).toList();
  }

  Match findById(String id) {
    return _items.firstWhere((match) => match.id == id);
  }

  Future<void> addMatch(Match match) async {
    const url = 'https://football-tracker-3e8cc.firebaseio.com/matches';
    try {
      await http.post(url,
          body: json.encode({
            'homeTeam': 'ksjdf',
            'awayTeam': 'ksajhdfk',
            'isWon': true,
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
        loadedMatches.add(Match(
          id: matchId,
          homeTeam: matchData['homeTeam'],
          awayTeam: matchData['awayTeam'],
          isWon: matchData['isWon'],
          dateTime: DateTime.now(),
          score: [0, 0],
        ));
      });
      _items = loadedMatches;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  void deleteMatch(String matchId) {
    _items.remove(matchId);
    notifyListeners();
    // print(_items.length);
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings with ChangeNotifier {
  List<String> _defaultTeams = [];

  List<String> get defaultTeams {
    return _defaultTeams;
  }

  Settings(this._defaultTeams);

  addTeam(String team) {
    _defaultTeams.add(team);
    notifyListeners();
    updatePrefs();
  }

  void deleteTeam(String team) {
    _defaultTeams.remove(team);
    notifyListeners();
    updatePrefs();
  }

  void updatePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('appSettings', _defaultTeams);
  }

  bool checkTeamForExisting(String team) {
    final isExisting = _defaultTeams.indexWhere((element) => element == team);
    if (isExisting == -1) return false;
    return true;
  }
}

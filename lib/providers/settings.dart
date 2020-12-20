import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings with ChangeNotifier {
  List<String> defaultTeams = [];

  initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    defaultTeams = prefs.getStringList('settingsDefaultTeams');
  }

  addTeam(String team) {
    defaultTeams.add(team.trim());
    notifyListeners();
    updatePrefs();
  }

  void deleteTeam(String team) {
    defaultTeams.remove(team);
    notifyListeners();
    updatePrefs();
  }

  void updatePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('settingsDefaultTeams', defaultTeams);
  }

  bool checkTeamForExisting(String team) {
    final isExisting = defaultTeams.indexWhere((element) => element == team);
    if (isExisting == -1) return false;
    return true;
  }
}

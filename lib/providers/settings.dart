import 'package:flutter/material.dart';
import 'package:football_provider_app/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings with ChangeNotifier {
  List<String> defaultTeams = [];
  int defaultHaltTimeLength = 45;

  initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    defaultTeams = prefs.getStringList('settingsDefaultTeams');
    defaultHaltTimeLength = prefs.getInt('settingsDefaultHaltTimeLength');
  }

  updateTeamChips(List<TeamChip> teamChips) {
    List<String> teamName = teamChips.map((e) => e.name).toList();
    defaultTeams = teamName;
    notifyListeners();
    updatePrefs();
  }

  updateHalfTimeLength(int length) {
    defaultHaltTimeLength = length;
    notifyListeners();
    updatePrefs();
  }

  void updatePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('settingsDefaultTeams', defaultTeams);
    prefs.setInt('settingsDefaultHaltTimeLength', defaultHaltTimeLength);
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_football_tracker/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  bool _isEmailVerified;

  List<String> _defaultTeams = [];

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  bool get isEmailVerified {
    return _isEmailVerified;
  }

  List<String> get defaultTeams {
    return _defaultTeams;
  }

  Future<bool> sendValidationEmail() async {
    print('sending..');
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyByKh5Jee44_PGxhfkIk0TrNhsi0xeYvSs';
    try {
      final response = await http.post(url,
          body: json.encode({
            'requestType': 'VERIFY_EMAIL',
            'idToken': token,
          }));
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyByKh5Jee44_PGxhfkIk0TrNhsi0xeYvSs';
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      setSettings();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);

      //send verification email
      if (urlSegment == 'signUp') {
        sendValidationEmail();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    setSettings();

    notifyListeners();
    // _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  // void _autoLogout() {
  //   if (_authTimer != null) {
  //     _authTimer.cancel();
  //   }
  //   final timeToExpiry = _expiryDate.difference(DateTime.now()).inDays + 30;
  //   _authTimer = Timer(Duration(days: timeToExpiry), logout);
  // }

  void setSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('settingsDefaultTeams')) {
      prefs.setStringList('settingsDefaultTeams', []);
    }
    if (!prefs.containsKey('settingsDefaultHalfTimeLength')) {
      prefs.setInt(
        'settingsDefaultHalfTimeLength',
        45,
      );
    }
  }

  Future<bool> resetPassword(String email) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyByKh5Jee44_PGxhfkIk0TrNhsi0xeYvSs';

    try {
      final response = await http.post(url,
          body: jsonEncode({
            'requestType': 'PASSWORD_RESET',
            'email': email,
          }));
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      return true;
    } catch (error) {
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/matches_screen.dart';
import './screens/settings_screen.dart';
import './screens/match_detail_screen.dart';
import 'screens/add_match_post_match_screen.dart';
import './providers/matches.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => MatchesProvider(),
      child: MaterialApp(
        title: 'MyMatches',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
        ),
        home: MatchesScreen(),
        routes: {
          MatchDetailScreen.routeName: (ctx) => MatchDetailScreen(),
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
          AddMatchPostMatchScreen.routeName: (ctx) => AddMatchPostMatchScreen(),
        },
      ),
    );
  }
}

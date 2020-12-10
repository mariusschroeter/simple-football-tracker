import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:football_provider_app/screens/onboarding_screen.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:provider/provider.dart';

import './screens/settings_screen.dart';
import './screens/match_detail_screen.dart';
import 'screens/add_match_post_match_screen.dart';
import './providers/matches.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: GlobalColors.primary,
    ));
    return ChangeNotifierProvider(
      create: (ctx) => MatchesProvider(),
      child: MaterialApp(
        title: 'MyMatches',
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.dark,
          primaryColor: GlobalColors.primary,
          accentColor: GlobalColors.accent,
          // Define the default font family.
          fontFamily: 'Georgia',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          ),
        ),
        home: OnboardingScreen(),
        routes: {
          MatchDetailScreen.routeName: (ctx) => MatchDetailScreen(),
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
          AddMatchPostMatchScreen.routeName: (ctx) => AddMatchPostMatchScreen(),
        },
      ),
    );
  }
}

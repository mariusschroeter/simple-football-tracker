import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_football_tracker/providers/settings.dart';
import 'package:simple_football_tracker/providers/auth.dart';
import 'package:simple_football_tracker/screens/auth_screen.dart';
import 'package:simple_football_tracker/screens/matches_screen.dart';
import 'package:simple_football_tracker/screens/splash_screen.dart';
import 'package:simple_football_tracker/widgets/global_colors.dart';
import 'package:provider/provider.dart';

import './screens/settings_screen.dart';
import './screens/match_detail_screen.dart';
import 'screens/add_match_pre_match_screen.dart';
import './providers/matches.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload' + payload);
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: GlobalColors.primary,
    ));
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => AuthProvider()),
          ChangeNotifierProxyProvider<AuthProvider, MatchesProvider>(
            create: null,
            update: (ctx, auth, previousMatches) => MatchesProvider(
              auth.token,
              auth.userId,
              previousMatches == null ? [] : previousMatches.items,
            ),
          ),
          ChangeNotifierProvider(create: (ctx) => Settings()),
        ],
        child: Consumer<AuthProvider>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'MyMatches',
            theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: GlobalColors.primary,
              accentColor: GlobalColors.accent,
              fontFamily: 'Roboto',
              textTheme: TextTheme(
                headline1:
                    TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
              ),
            ),
            home: auth.isAuth
                ? MatchesScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              MatchesScreen.routeName: (ctx) => MatchesScreen(),
              MatchDetailScreen.routeName: (ctx) => MatchDetailScreen(),
              SettingsScreen.routeName: (ctx) => SettingsScreen(),
              AddMatchPreMatchScreen.routeName: (ctx) =>
                  AddMatchPreMatchScreen(),
            },
          ),
        ));
  }
}

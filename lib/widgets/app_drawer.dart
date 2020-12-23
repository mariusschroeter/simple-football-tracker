import 'package:flutter/material.dart';
import 'package:simple_football_tracker/providers/auth.dart';
import 'package:simple_football_tracker/screens/matches_screen.dart';
import 'package:simple_football_tracker/widgets/app_bar_logo_and_title.dart';
import 'package:simple_football_tracker/widgets/global_colors.dart';
import 'package:provider/provider.dart';

import '../screens/settings_screen.dart';

class AppDrawer extends StatefulWidget {
  final List<FocusNode> nodesToUnfocus;

  AppDrawer({this.nodesToUnfocus});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    super.initState();
    if (widget.nodesToUnfocus != null) {
      widget.nodesToUnfocus.forEach((element) {
        element.unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: AppBarLogoAndTitle(
              title: 'Simple Football Tracker',
            ),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: const Text('Matches'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(MatchesScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(SettingsScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title:
                Text('Logout', style: TextStyle(color: GlobalColors.secondary)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}

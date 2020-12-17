import 'package:flutter/material.dart';
import 'package:football_provider_app/providers/auth.dart';
import 'package:football_provider_app/screens/matches_screen.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:provider/provider.dart';

import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Hello Friend'),
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

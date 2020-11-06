import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/matches.dart';

class MatchDetailScreen extends StatelessWidget {
  static const routeName = "/match-detail";


  //Hier kommen dann die ganzen Statistiken rein
  //Einfach ein Graph der auch die Highlights enthält(Wann ist ein Tor gefallen)
  @override
  Widget build(BuildContext context) {
    final matchId = ModalRoute.of(context).settings.arguments as String;
    final loadedMatch =
        Provider.of<MatchesProvider>(context, listen: false).findById(matchId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedMatch.homeTeam),
      ),
    );
  }
}

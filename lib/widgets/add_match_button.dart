import 'package:flutter/material.dart';

import '../screens/add_match_pre_match_screen.dart';

class AddMatchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        Scaffold.of(context).removeCurrentSnackBar();
        var matchResponse =
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AddMatchPreMatchScreen();
        }));
        if (matchResponse != null) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(matchResponse),
          ));
        }
      },
      child: Icon(Icons.add),
    );
  }
}

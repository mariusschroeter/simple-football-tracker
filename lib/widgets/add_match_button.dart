import 'package:flutter/material.dart';

import '../screens/add_match_post_match_screen.dart';

class AddMatchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Match added!'),
        ));
        // matches.addMatch(match)
        //Add Screen on top of the stack and save the match result
        var matchResult =
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AddMatchPostMatchScreen();
        }));

        print(matchResult);
        //if (matchResult != null) //add match
      },
      child: Icon(Icons.add),
    );
  }
}

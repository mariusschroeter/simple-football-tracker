import 'package:flutter/material.dart';

import '../screens/add_match_pre_match_screen.dart';
import 'global_colors.dart';

class AddMatchButton extends StatelessWidget {
  final bool isEmailVerified;

  AddMatchButton({this.isEmailVerified});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: isEmailVerified
          ? GlobalColors.primary
          : Theme.of(context).disabledColor,
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

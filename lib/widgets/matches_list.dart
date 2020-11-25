import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/matches.dart';
import '../screens/match_detail_screen.dart';

class MatchesList extends StatelessWidget {
  final bool showWon;

  MatchesList(this.showWon);

  @override
  Widget build(BuildContext context) {
    final matchesData = Provider.of<MatchesProvider>(context);
    final matches = showWon ? matchesData.wonItems : matchesData.items;
    return ListView.builder(
      itemBuilder: (ctx, i) => Dismissible(
        key: ValueKey(matches[i].id),
        background: Container(
          color: Theme.of(context).errorColor,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('Do you want to remove the match?'),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                      ),
                      FlatButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                      )
                    ],
                  ));
        },
        onDismissed: (direction) {
          try {
            Provider.of<MatchesProvider>(context, listen: false)
                .deleteMatch(matches[i].id);
          } catch (e) {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Deleting failed.'),
            ));
          }
        },
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(MatchDetailScreen.routeName,
                arguments: matches[i].id);
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                // leading:
                // CircleAvatar(
                //   child: Padding(
                //     padding: const EdgeInsets.all(5.0),
                //     child: FittedBox(child: Text('\$$price')),
                //   ),
                // ),
                title: Text(matches[i].homeTeam + ' vs ' + matches[i].awayTeam),
                subtitle:
                    Text(DateFormat('dd.MM.yyyy').format(matches[i].dateTime)),
                trailing: Text('0 : 0'),
              ),
            ),
          ),
        ),
      ),
      itemCount: matches.length,
    );
  }
}

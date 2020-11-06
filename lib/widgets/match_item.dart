// import 'package:flutter/material.dart';

// import '../screens/match_detail_screen.dart';

// class MatchItem extends StatelessWidget {
//   const MatchItem({
//     Key key,
//     @required this.matches,
//   }) : super(key: key);

//   final List<Match> matches;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context)
//             .pushNamed(MatchDetailScreen.routeName, arguments: matches[i].id);
//       },
//       child: ListTile(
//         title: Text(
//           matches[i].homeTeam + " vs " + matches[i].awayTeam,
//         ),
//         trailing: Text(
//           "1 : 0",
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }

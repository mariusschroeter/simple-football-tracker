import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/app_bar_logo_and_title.dart';
import 'package:football_provider_app/widgets/bottom_dialog.dart';
import 'package:football_provider_app/widgets/svg.dart';
import 'package:provider/provider.dart';

import '../providers/matches.dart';
import '../widgets/matches_list.dart';
import '../widgets/app_drawer.dart';
import '../widgets/add_match_button.dart';

enum FilterOptions {
  NEWEST_FIRST,
  OLDEST_FIRST,
}

class MatchesScreen extends StatefulWidget {
  static const routeName = '/matches';

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  var _showNewestFirst = true;
  var _isLoading = false;

  bool _showDialog;

  Future<void> _refreshMatches() async {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<MatchesProvider>(context, listen: false)
          .fetchAndSetMatches()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  void initState() {
    _refreshMatches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final matchesLength = Provider.of<MatchesProvider>(context).items.length;
    _showDialog = matchesLength == 0;
    return Scaffold(
      appBar: AppBar(
        title: AppBarLogoAndTitle(
          title: 'Tracked Matches',
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.NEWEST_FIRST) {
                  _showNewestFirst = true;
                } else {
                  _showNewestFirst = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Newest First"),
                value: FilterOptions.NEWEST_FIRST,
              ),
              PopupMenuItem(
                  child: Text("Oldest First"),
                  value: FilterOptions.OLDEST_FIRST)
            ],
          ),
        ],
      ),
      drawer: AppDrawer(),
      floatingActionButton: AddMatchButton(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshMatches(),
              child: Stack(
                children: <Widget>[
                  _showDialog
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 64.0),
                          child: BottomDialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      24.0, 20.0, 24.0, 24.0),
                                  child: Text('Here you can track new matches',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 20.0, 10.0, 20.0),
                                    child: Icon(
                                      Icons.arrow_downward,
                                      size: 36.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // title: Text('Here you can track new matches'),
                            // content: Text(''),
                            // actions: [
                            //   FlatButton(
                            //     child: Text('Ok'),
                            //     onPressed: () {
                            //       setState(() {
                            //         _showDialog = false;
                            //       });
                            //     },
                            //   )
                            // ],
                          ),
                        )
                      : SizedBox(),
                  Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: MatchesList(_showNewestFirst),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

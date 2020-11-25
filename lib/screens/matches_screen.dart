import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/matches.dart';
import '../widgets/matches_list.dart';
import '../widgets/app_drawer.dart';
import '../widgets/add_match_button.dart';

enum FilterOptions {
  Won,
  All,
}

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  var _showWonOnly = false;
  var _isLoading = false;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Matches Screen"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Won) {
                  _showWonOnly = true;
                } else {
                  _showWonOnly = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Only Won"),
                value: FilterOptions.Won,
              ),
              PopupMenuItem(child: Text("Show All"), value: FilterOptions.All)
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
              child: Container(
                child: Column(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: MatchesList(_showWonOnly),
                    ))
                  ],
                ),
              ),
            ),
    );
  }
}

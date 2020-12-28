import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:simple_football_tracker/providers/auth.dart';
import 'package:simple_football_tracker/widgets/app_bar_logo_and_title.dart';
import 'package:simple_football_tracker/widgets/custom_align_dialog.dart';
import 'package:provider/provider.dart';
import 'package:simple_football_tracker/widgets/global_colors.dart';

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
  var _isEmailVerified = false;

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

  _checkEmail() async {
    final emailVerified =
        await Provider.of<MatchesProvider>(context, listen: false)
            .getCurrentUserData();
    setState(() {
      _isEmailVerified = emailVerified;
    });
    if (!_isEmailVerified) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => showAlertDialog(context));
    }
  }

  _sendVerificationEmailAgain(BuildContext context) async {
    final response = await Provider.of<AuthProvider>(context, listen: false)
        .sendValidationEmail();
    final snackBarText =
        response ? 'Verification email send!' : 'Try again later please!';
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(snackBarText)));
  }

  @override
  void initState() {
    _refreshMatches();
    _checkEmail();
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
                  _showDialog && _isEmailVerified
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 64.0),
                          child: CustomAlignDialog(
                            align: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      24.0, 20.0, 24.0, 0.0),
                                  child: Text('Here you can track new matches',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0.0, 10.0, 20.0),
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
                  !_isEmailVerified
                      ? CustomAlignDialog(
                          align: Alignment.topCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    24.0, 20.0, 24.0, 0.0),
                                child: Text(
                                  'Email not verified! Your matches will not be saved!',
                                  style:
                                      TextStyle(color: GlobalColors.secondary),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0.0, 10.0, 20.0),
                                    child: FlatButton(
                                        onPressed: () {
                                          _sendVerificationEmailAgain(context);
                                        },
                                        child: Text('Resent email'))),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
    );
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verification email send!'),
          content: Text('Check your email inbox.'),
          actions: [okButton],
        );
      },
    );
  }
}

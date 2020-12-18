import 'package:flutter/material.dart';
import 'package:football_provider_app/screens/add_match_start_match.screen.dart';
import 'package:football_provider_app/widgets/global_colors.dart';

class AddMatchPostMatchScreen extends StatefulWidget {
  static const routeName = '/add-match';

  @override
  _AddMatchPostMatchScreenState createState() =>
      _AddMatchPostMatchScreenState();
}

class _AddMatchPostMatchScreenState extends State<AddMatchPostMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeTeam = TextEditingController();
  final _homeTeamAbb = TextEditingController();
  final _awayTeam = TextEditingController();
  final _awayTeamAbb = TextEditingController();

  _checkInputs(String teamName) {
    if (teamName.isEmpty) return 'Please enter some text';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Match Settings'),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            controller: _homeTeam,
                            decoration: InputDecoration(hintText: 'Home Team'),
                            validator: (value) {
                              return _checkInputs(value);
                            },
                            onChanged: (_) {
                              if (_homeTeam.text.length > 0 &&
                                  _homeTeam.text.length < 4) {
                                setState(() {
                                  _homeTeamAbb.text = _homeTeam.text
                                      .substring(0, _homeTeam.text.length)
                                      .trim();
                                });
                              }
                            },
                            cursorColor: GlobalColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            controller: _homeTeamAbb,
                            decoration: InputDecoration(
                                hintText: 'Abb.', counterText: ''),
                            validator: (value) {
                              return _checkInputs(value);
                            },
                            maxLength: 3,
                            cursorColor: GlobalColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            controller: _awayTeam,
                            decoration: InputDecoration(
                              hintText: 'Away Team',
                            ),
                            validator: (value) {
                              return _checkInputs(value);
                            },
                            onChanged: (_) {
                              if (_awayTeam.text.length > 0 &&
                                  _awayTeam.text.length < 4) {
                                setState(() {
                                  _awayTeamAbb.text = _awayTeam.text
                                      .substring(0, _awayTeam.text.length)
                                      .trim();
                                });
                              }
                            },
                            cursorColor: GlobalColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            controller: _awayTeamAbb,
                            decoration: InputDecoration(
                                hintText: 'Abb.', counterText: ''),
                            validator: (value) {
                              return _checkInputs(value);
                            },
                            maxLength: 3,
                            cursorColor: GlobalColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      enabled: false,
                      controller: null,
                      decoration:
                          InputDecoration(hintText: 'Zones to track: 6'),
                      // validator: (value) {
                      //   return _checkInputs(value);
                      // },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      enabled: false,
                      controller: null,
                      decoration: InputDecoration(hintText: 'Field Width: 45m'),
                      // validator: (value) {
                      //   return _checkInputs(value);
                      // },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      enabled: false,
                      controller: null,
                      decoration:
                          InputDecoration(hintText: 'Field Height: 90m'),
                      // validator: (value) {
                      //   return _checkInputs(value);
                      // },
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            var matchResponse = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return AddMatchStartMatchScreen(
                homeTeam: _homeTeam.text,
                awayTeam: _awayTeam.text,
                homeTeamAbb: _homeTeamAbb.text,
                awayTeamAbb: _awayTeamAbb.text,
              );
            }));
            Navigator.pop(context, matchResponse);
          }
        },
        tooltip: 'Start Match',
        child: Icon(Icons.subdirectory_arrow_right),
      ),
    );
  }
}

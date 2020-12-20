import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:football_provider_app/providers/settings.dart';
import 'package:football_provider_app/screens/add_match_start_match.screen.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:provider/provider.dart';

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
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
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
                            child: TypeAheadFormField(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _homeTeam,
                                decoration:
                                    InputDecoration(labelText: 'Home Team'),
                                onChanged: (value) {
                                  final teamTextLength = _homeTeam.text.length;
                                  if (teamTextLength >= 0 &&
                                      teamTextLength < 4) {
                                    final teamAbb = teamTextLength == 0
                                        ? ''
                                        : teamTextLength < 3
                                            ? _homeTeam.text
                                            : _homeTeam.text
                                                .substring(0, 3)
                                                .trim();
                                    setState(() {
                                      _homeTeamAbb.text = teamAbb;
                                    });
                                  }
                                },
                              ),
                              suggestionsCallback: (pattern) {
                                final defaultTeams = Provider.of<Settings>(
                                        context,
                                        listen: false)
                                    .defaultTeams;
                                return defaultTeams.where(
                                    (element) => element.startsWith(pattern));
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion),
                                );
                              },
                              transitionBuilder:
                                  (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              onSuggestionSelected: (suggestion) {
                                final teamAbb = suggestion.length > 3
                                    ? suggestion.substring(0, 3).trim()
                                    : suggestion;
                                setState(() {
                                  _homeTeam.text = suggestion;
                                  _homeTeamAbb.text = teamAbb;
                                });
                              },
                              validator: (value) {
                                return _checkInputs(value);
                              },
                              onSaved: (value) => _homeTeam.text = value,
                              noItemsFoundBuilder: (ctx) => Container(
                                height: 0,
                              ),
                              animationDuration: Duration(milliseconds: 100),
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
                                  labelText: 'Abb.', counterText: ''),
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
                            child: TypeAheadFormField(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _awayTeam,
                                decoration:
                                    InputDecoration(labelText: 'Away Team'),
                                onChanged: (value) {
                                  final teamTextLength = _awayTeam.text.length;
                                  if (teamTextLength >= 0 &&
                                      teamTextLength < 4) {
                                    final teamAbb = teamTextLength == 0
                                        ? ''
                                        : teamTextLength < 3
                                            ? _awayTeam.text
                                            : _awayTeam.text
                                                .substring(0, 3)
                                                .trim();
                                    setState(() {
                                      _awayTeamAbb.text = teamAbb;
                                    });
                                  }
                                },
                              ),
                              suggestionsCallback: (pattern) {
                                return Provider.of<Settings>(context,
                                        listen: false)
                                    .defaultTeams
                                    .where((element) =>
                                        element.startsWith(pattern));
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion),
                                );
                              },
                              transitionBuilder:
                                  (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              onSuggestionSelected: (suggestion) {
                                final teamAbb = suggestion.length > 3
                                    ? suggestion.substring(0, 3).trim()
                                    : suggestion;
                                setState(() {
                                  _awayTeam.text = suggestion;
                                  _awayTeamAbb.text = teamAbb;
                                });
                              },
                              validator: (value) {
                                return _checkInputs(value);
                              },
                              onSaved: (value) => _awayTeam.text = value,
                              noItemsFoundBuilder: (ctx) => Container(
                                height: 0,
                              ),
                              animationDuration: Duration(milliseconds: 100),
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
                                  labelText: 'Abb.', counterText: ''),
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
                            InputDecoration(labelText: 'Zones to track: 6'),
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
                            InputDecoration(labelText: 'Field Width: 45m'),
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
                            InputDecoration(labelText: 'Field Height: 90m'),
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

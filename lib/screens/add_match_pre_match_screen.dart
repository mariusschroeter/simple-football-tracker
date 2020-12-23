import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:simple_football_tracker/providers/settings.dart';
import 'package:simple_football_tracker/screens/add_match_start_match.screen.dart';
import 'package:simple_football_tracker/widgets/app_bar_logo_and_title.dart';
import 'package:simple_football_tracker/widgets/global_colors.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class AddMatchPreMatchScreen extends StatefulWidget {
  static const routeName = '/add-match';

  @override
  _AddMatchPreMatchScreenState createState() => _AddMatchPreMatchScreenState();
}

class _AddMatchPreMatchScreenState extends State<AddMatchPreMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeTeam = TextEditingController();
  final _homeTeamAbb = TextEditingController();
  final _awayTeam = TextEditingController();
  final _awayTeamAbb = TextEditingController();
  int _halfTimeValue = 45;
  final _halfTimeLength = TextEditingController(text: '45');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initHalfTimeValue();
    Provider.of<Settings>(context).initSettings();
  }

  _checkInputs(String teamName) {
    if (teamName.isEmpty) return 'Please enter some text';
    if (_homeTeam.text == _awayTeam.text) return 'Two different team names';
    if (_homeTeamAbb.text == _awayTeamAbb.text)
      return 'Two different team abbreviations';
    return null;
  }

  _initHalfTimeValue() {
    final length = Provider.of<Settings>(context).defaultHaltTimeLength;
    setState(() {
      _halfTimeValue = length;
      _halfTimeLength.text = length.toString();
    });
  }

  _checkHalfTimeValue(String value) {
    _checkInputs(value);
    if (int.tryParse(value) == null) {
      return 'Please enter a number';
    }
    if (int.tryParse(value) > 45 || int.tryParse(value) < 1) {
      return 'Please enter a number (1-45)';
    }
    return null;
  }

  _updateHalfTimeValue(int value) {
    setState(() {
      _halfTimeValue = value;
      _halfTimeLength.text = value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarLogoAndTitle(
          title: 'Pre Match Settings',
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
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
                                cursorColor: GlobalColors.primary,
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
                                labelText: 'Abb.',
                                counterText: '',
                              ),
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
                                cursorColor: GlobalColors.primary,
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
                        child: Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: TextFormField(
                                controller: _halfTimeLength,
                                decoration: InputDecoration(
                                  labelText: 'Half Time Length (minutes)',
                                  counterText: '',
                                ),
                                validator: (value) {
                                  return _checkHalfTimeValue(value);
                                },
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                cursorColor: GlobalColors.primary,
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: NumberPicker.integer(
                                initialValue: _halfTimeValue,
                                minValue: 1,
                                maxValue: 45,
                                onChanged: (value) =>
                                    _updateHalfTimeValue(value),
                                infiniteLoop: true,
                                itemExtent: 32.0,
                              ),
                            ),
                          ],
                        )),
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: TextFormField(
                    //     enabled: false,
                    //     controller: null,
                    //     decoration:
                    //         InputDecoration(labelText: 'Field Width: 45m'),
                    //     // validator: (value) {
                    //     //   return _checkInputs(value);
                    //     // },
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: TextFormField(
                    //     enabled: false,
                    //     controller: null,
                    //     decoration:
                    //         InputDecoration(labelText: 'Field Height: 90m'),
                    //     // validator: (value) {
                    //     //   return _checkInputs(value);
                    //     // },
                    //   ),
                    // ),
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
                halfTimeLength: _halfTimeValue,
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

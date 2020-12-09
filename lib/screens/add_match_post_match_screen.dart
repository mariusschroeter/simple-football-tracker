import 'package:flutter/material.dart';
import 'package:football_provider_app/screens/add_match_start_match.screen.dart';

class AddMatchPostMatchScreen extends StatefulWidget {
  static const routeName = '/add-match';

  @override
  _AddMatchPostMatchScreenState createState() =>
      _AddMatchPostMatchScreenState();
}

class _AddMatchPostMatchScreenState extends State<AddMatchPostMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeTeam = TextEditingController();
  final _awayTeam = TextEditingController();

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
      body: Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _homeTeam,
              decoration: InputDecoration(hintText: 'Home Team'),
              validator: (value) {
                return _checkInputs(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _awayTeam,
              decoration: InputDecoration(hintText: 'Away Team'),
              validator: (value) {
                return _checkInputs(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              enabled: false,
              controller: null,
              decoration: InputDecoration(hintText: 'Zones to track: 6'),
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
              decoration: InputDecoration(hintText: 'Field Height: 90m'),
              // validator: (value) {
              //   return _checkInputs(value);
              // },
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            var matchResponse = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return AddMatchStartMatchScreen(
                  homeTeam: _homeTeam.text, awayTeam: _awayTeam.text);
            }));
            Navigator.pop(context, matchResponse);
          }
        },
        tooltip: 'Start Match',
        child: Icon(Icons.arrow_right_alt),
      ),
    );
  }
}

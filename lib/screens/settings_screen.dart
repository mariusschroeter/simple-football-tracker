import 'package:flutter/material.dart';
import 'package:football_provider_app/providers/settings.dart';
import 'package:football_provider_app/widgets/app_drawer.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _team = TextEditingController();

  List<Widget> _teamChips = [];

  @override
  void didChangeDependencies() {
    _initSettings();
    super.didChangeDependencies();
  }

  void _initSettings() async {
    await Provider.of<Settings>(context, listen: false).initSettings();
    _updateDefaultTeams();
  }

  void _updateDefaultTeams() {
    List<String> defaultTeams =
        Provider.of<Settings>(context, listen: false).defaultTeams;
    List<Widget> currTeams = [];
    if (defaultTeams.length > 0) {
      defaultTeams.forEach((element) {
        final initials =
            element.split(" ").map((e) => e[0]).join().toUpperCase();
        currTeams.add(Chip(
          avatar: CircleAvatar(
            backgroundColor: GlobalColors.primary,
            child: Text(initials),
          ),
          label: Text(element),
          onDeleted: () => {
            Provider.of<Settings>(context, listen: false).deleteTeam(element),
            _updateDefaultTeams(),
          },
          deleteIcon: Icon(Icons.close),
          elevation: 4.0,
        ));
      });
    }
    setState(() {
      _teamChips = currTeams;
    });
  }

  _checkInputs(String input) {
    if (input.isEmpty) return 'Please enter some text';
    if (Provider.of<Settings>(context, listen: false)
        .checkTeamForExisting(input)) return 'Team already existing';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      drawer: AppDrawer(),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 8.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                controller: _team,
                                decoration: InputDecoration(
                                    labelText: 'Add Default Teams'),
                                validator: (value) {
                                  return _checkInputs(value);
                                },
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                color: _team.text.isNotEmpty
                                    ? GlobalColors.primary
                                    : Theme.of(context).disabledColor,
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  Provider.of<Settings>(context, listen: false)
                                      .addTeam(_team.text);
                                  _updateDefaultTeams();
                                  _team.clear();
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Wrap(
                    spacing: 8.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    children: _teamChips ?? [],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

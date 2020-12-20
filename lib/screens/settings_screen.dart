import 'package:flutter/material.dart';
import 'package:football_provider_app/providers/settings.dart';
import 'package:football_provider_app/widgets/app_drawer.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _team = TextEditingController();

  int _halfTimeValue = 45;
  final _halfTimeLength = TextEditingController();

  List<TeamChip> _teamChips = [];

  @override
  void didChangeDependencies() {
    _initSettings();
    super.didChangeDependencies();
  }

  void _initSettings() async {
    await Provider.of<Settings>(context, listen: false).initSettings();
    _updateDefaultTeams();
    _updateDefaultHalfTimeLength();
  }

  void _updateDefaultHalfTimeLength() {
    final defaultLength =
        Provider.of<Settings>(context, listen: false).defaultHaltTimeLength;
    setState(() {
      _halfTimeValue = defaultLength;
      _halfTimeLength.text = defaultLength.toString();
    });
  }

  void _updateDefaultTeams() {
    List<String> defaultTeams =
        Provider.of<Settings>(context, listen: false).defaultTeams;
    List<TeamChip> currTeams = [];
    if (defaultTeams.length > 0) {
      defaultTeams.forEach((element) {
        final initials =
            element.split(" ").map((e) => e[0]).join().toUpperCase();
        currTeams.add(
          TeamChip(
            initials: initials,
            name: element,
            deleteChip: _deleteChip,
          ),
        );
      });
    }
    setState(() {
      _teamChips = currTeams;
    });
  }

  _checkInputs(String input) {
    if (input.isEmpty) return 'Please enter some text';
    if (_checkTeamForExisting(input)) return 'Team already exists';
    return null;
  }

  bool _checkTeamForExisting(String team) {
    final isExisting = _teamChips.indexWhere((element) => element.name == team);
    if (isExisting == -1) return false;
    return true;
  }

  _updateHalfTimeValue(int value) {
    setState(() {
      _halfTimeValue = value;
      _halfTimeLength.text = value.toString();
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

  _addTeamChip() {
    final initials =
        _team.text.split(" ").map((e) => e[0]).join().toUpperCase();
    setState(() {
      _teamChips.add(TeamChip(
        initials: initials,
        name: _team.text.trim(),
        deleteChip: _deleteChip,
      ));
    });
  }

  _deleteChip(String name) {
    setState(() {
      _teamChips.removeWhere((item) => item.name == name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          Builder(
            builder: (context) => IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  Provider.of<Settings>(context, listen: false)
                      .updateTeamChips(_teamChips);
                  _updateDefaultTeams();
                  FocusScope.of(context).unfocus();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Settings saved!'),
                  ));
                }),
          )
        ],
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Row(
                    //   children: [
                    //     Flexible(
                    //       flex: 2,
                    //       child: TextFormField(
                    //         controller: _halfTimeLength,
                    //         decoration: InputDecoration(
                    //           labelText: 'Half Time Length (minutes)',
                    //           counterText: '',
                    //         ),
                    //         validator: (value) {
                    //           return _checkHalfTimeValue(value);
                    //         },
                    //         autovalidateMode: AutovalidateMode.always,
                    //         keyboardType: TextInputType.number,
                    //         maxLength: 2,
                    //         cursorColor: GlobalColors.primary,
                    //       ),
                    //     ),
                    //     Flexible(
                    //       flex: 1,
                    //       child: NumberPicker.integer(
                    //         initialValue: _halfTimeValue,
                    //         minValue: 1,
                    //         maxValue: 45,
                    //         onChanged: (value) => {
                    //           _updateHalfTimeValue(value),
                    //         },
                    //         infiniteLoop: true,
                    //         itemExtent: 32.0,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            controller: _team,
                            decoration:
                                InputDecoration(labelText: 'Add Default Teams'),
                            validator: (value) {
                              return _checkInputs(value);
                            },
                            onChanged: (value) {
                              _checkHalfTimeValue(value);
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
                              _addTeamChip();
                              _team.clear();
                            }
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _teamChips ?? [],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TeamChip extends StatelessWidget {
  const TeamChip({
    Key key,
    @required this.initials,
    @required this.name,
    @required this.deleteChip,
  }) : super(key: key);

  final String initials;
  final String name;
  final Function deleteChip;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: GlobalColors.primary,
        child: Text(
          initials,
          style: TextStyle(fontSize: 12),
        ),
      ),
      label: Text(name),
      onDeleted: () => {
        // Provider.of<Settings>(context, listen: false).deleteTeam(name),
        // updateDefaultTeams(),
        deleteChip(name),
      },
      deleteIcon: Icon(Icons.close),
      elevation: 4.0,
    );
  }
}

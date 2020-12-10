import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/global_colors.dart';
import 'package:football_provider_app/widgets/svg.dart';

class AppDrawerInMatch extends StatelessWidget {
  final Function switchHeatMap;
  final Function switchPercentages;
  final Function switchZones;
  final bool zones;
  final bool heatmap;
  final bool percentages;

  AppDrawerInMatch(
      {this.switchHeatMap,
      this.switchPercentages,
      this.switchZones,
      this.zones,
      this.heatmap,
      this.percentages});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Match Settings'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          SwitchListTile(
            activeColor: GlobalColors.primary,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Svg(
                    name: 'icon_zone',
                    height: 20.0,
                    width: 20.0,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text('Show Zones'),
                    )),
              ],
            ),
            value: zones,
            onChanged: (_) => switchZones(!zones),
          ),
          Divider(),
          SwitchListTile(
            activeColor: GlobalColors.primary,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Svg(
                    name: 'icon_percentage',
                    height: 20.0,
                    width: 20.0,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text('Show Percentages'),
                    )),
              ],
            ),
            value: percentages,
            onChanged: (_) => switchPercentages(!percentages),
          ),
          Divider(),
          SwitchListTile(
            activeColor: GlobalColors.primary,
            title: Row(
              children: [
                Icon(Icons.invert_colors),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text('Show Heatmap'),
                    )),
              ],
            ),
            value: heatmap,
            onChanged: (_) => switchHeatMap(!heatmap),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.close),
            title: Text(
              'End match now',
              style: TextStyle(color: GlobalColors.secondary),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop('Match has been ended!');
            },
          )
        ],
      ),
    );
  }
}

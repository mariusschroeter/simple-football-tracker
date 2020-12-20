import 'package:flutter/material.dart';
import 'package:football_provider_app/widgets/svg.dart';

class AppBarLogoAndTitle extends StatelessWidget {
  AppBarLogoAndTitle({this.title, this.logo = 'logo_trans'});

  final String title;
  final String logo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Svg(
          name: logo,
          height: 60,
          width: 60,
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Svg extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  final BoxFit fit;
  final Color color;

  Svg(
      {@required this.name,
      this.width = 0,
      this.height = 0,
      this.fit = BoxFit.contain,
      this.color});

  @override
  Widget build(BuildContext context) {
    return width <= 0 || height <= 0
        ? SvgPicture.asset(
            'lib/resources/images/' + name + '.svg',
            semanticsLabel: name,
            color: color,
          )
        : SizedBox(
            width: width,
            height: height,
            child: SvgPicture.asset(
              'lib/resources/images/' + name + '.svg',
              semanticsLabel: name,
              fit: fit,
              color: color,
            ),
          );
  }
}

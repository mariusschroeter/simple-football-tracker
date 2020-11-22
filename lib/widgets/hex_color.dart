import 'package:flutter/material.dart';

class HexColor extends Color {
  HexColor(String hexString) : super(_parseColor(hexString));

  static int _parseColor(String color) {
    try {
      color = color.toUpperCase().replaceAll('#', '');
      if (color.length == 6) {
        color = 'FF' + color;
      }
    } on Exception catch (_) {
      return Colors.white.value;
    }
    return int.parse(color, radix: 16);
  }
}

import 'dart:io';

import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter/file_input.dart'; // For compatibility with flutter web.

void main(List<String> arguments) async {
  final file = File('lib/resources/images/football_field.jpg');
  final size = ImageSizeGetter.getSize(FileInput(file));
  print('jpg = $size');
}

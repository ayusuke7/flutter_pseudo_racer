import 'dart:ui' as ui;

import 'package:flutter/services.dart';

abstract class AssetsData {
  static late ui.Image player;
  static late ui.Image opponents;
  static late ui.Image tree;
  static late ui.Image skyClear;
  static late ui.Image skyDark;

  static Future<void> loadImages() async {
    tree = await _loadImage('assets/images/tree.png');
    player = await _loadImage('assets/images/player.png');
    opponents = await _loadImage('assets/images/opponents.png');
    skyClear = await _loadImage('assets/images/sky-clear.png');
    skyDark = await _loadImage('assets/images/sky-dark.png');
  }

  static Future<ui.Image> _loadImage(String imageAssetPath) async {
    final data = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }
}

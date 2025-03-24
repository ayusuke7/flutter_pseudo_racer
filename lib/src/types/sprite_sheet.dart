import 'dart:ui' as ui;

import 'vector.dart';

class SpriteSheet {
  final ui.Image image;

  Vector sprites;
  Vector position;
  Vector offset;

  SpriteSheet({
    required this.image,
    required this.sprites,
    required this.position,
    required this.offset,
  });

  int get width => image.width;

  int get height => image.height;

  double get spriteWidth => width / sprites.x;

  double get spriteHeight => height / sprites.y;

  ui.Rect toRect() => ui.Rect.fromLTWH(
        spriteWidth * position.x,
        spriteHeight * position.y,
        spriteWidth,
        spriteHeight,
      );

  ui.Rect toDest(double dx, double dy) => ui.Rect.fromLTWH(
        dx,
        dy,
        spriteWidth,
        spriteHeight,
      );
}

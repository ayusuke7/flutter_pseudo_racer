import 'dart:ui';

import 'vector.dart';

class Segment {
  int index;
  SegPoint point;
  SegColor colors;

  Segment({
    required this.index,
    required this.point,
    required this.colors,
  });
}

class SegPoint {
  Vector screen;
  Vector world;
  double scale;

  SegPoint({
    required this.world,
    required this.screen,
    required this.scale,
  });
}

class SegColor {
  Color road;
  Color grass;
  Color rumble;
  Color? lane;

  SegColor({
    required this.road,
    required this.grass,
    required this.rumble,
    this.lane,
  });
}

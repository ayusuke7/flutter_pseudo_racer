import 'dart:ui';

abstract class Component {
  double x;
  double y;
  double z;

  double width;
  double height;

  double scale;

  Component({
    this.x = 0,
    this.y = 0,
    this.z = 0,
    this.width = 0,
    this.height = 0,
    this.scale = 1.0,
  });

  void render(Canvas canvas, Size size);

  Size get resize => Size(width * scale, height * scale);
}

import 'dart:math';
import 'dart:ui';

import '../types/frame_time.dart';
import 'camera.dart';
import 'component.dart';
import 'road.dart';

class Player extends Component {
  late Road road;
  late Camera camera;

  double speed = 0;
  double maxSpeed = 0;
  double aceleration = 0.1;
  double deceleration = 0.3;

  Player({
    super.x,
    super.y,
    super.z,
  });

  void init() {
    maxSpeed = (road.segmentLength) / (1 / 40);
  }

  void update(FrameTime time) {
    z += speed * min(1, time.delta);

    if (z >= road.roadLength) {
      z -= road.roadLength;
    }
  }

  void reset() {
    x = 0;
    y = 0;
    z = 0;
    speed = maxSpeed;
  }

  void render(Canvas canvas, Size size) {}
}

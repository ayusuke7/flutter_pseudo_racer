import 'dart:math';

import '../types/frame_time.dart';
import 'camera.dart';
import 'component.dart';
import 'road.dart';

class Player extends Component {
  late Road road;
  late Camera camera;

  double speed = 0;
  double aceleration = 10.0;
  double deceleration = 30.0;

  Player({
    super.x,
    super.y,
    super.z,
  });

  double get maxSpeed => (road.segmentLength) / (1 / 60);

  void update(FrameTime time) {
    z += speed * min(1, time.delta);

    if (z >= road.roadLength) {
      z -= road.roadLength;
    }
  }

  void acelerate() {
    if (speed < maxSpeed) {
      speed += aceleration;
    }
  }

  void decelerate() {
    speed = 0;
    // if (speed > 0) {
    //   speed -= deceleration;
    // }
  }

  void stop() {
    speed = 0;
  }

  void reset() {
    x = 0;
    y = 0;
    z = 0;
    speed = maxSpeed;
  }

  @override
  String toString() {
    return 'Player =  XYZ: (${x.toInt()}, ${y.toInt()}, ${z.toInt()}) / Speed: $speed';
  }
}

import 'dart:math';
import 'dart:ui';

import 'package:flutter_fake_racer/src/data/assets.dart';
import 'package:flutter_fake_racer/src/types/vector.dart';

import '../types/frame_time.dart';
import 'component.dart';
import 'road.dart';

class Player extends Component {
  late Road road;

  double speed = 0;
  double aceleration = 10.0;
  double deceleration = 30.0;

  double distToPlane = 100;
  double distToPlayer = 500;

  int spriteIndex = 0;
  int maxFrames = 6;

  Vector cameraPosition = Vector(
    x: 0,
    z: 0,
    y: 1000,
  );

  Player({
    super.x,
    super.y,
    super.z,
    super.width = 172,
    super.height = 34,
    super.scale = 1.5,
  });

  double get maxSpeed => (road.segmentLength) / (1 / 60);

  void init() {
    distToPlane = 1 / (cameraPosition.y / distToPlayer);
    speed = maxSpeed;
  }

  void update(FrameTime time) {
    _updateSprite(time.previous);

    cameraPosition.x = x * road.roadWidth;
    cameraPosition.z = z - distToPlayer;

    if (cameraPosition.z < 0) {
      cameraPosition.z += road.roadLength;
    }

    z += speed * min(1, time.delta);
    if (z >= road.roadLength) {
      z -= road.roadLength;
    }
  }

  void _updateSprite(int milliseconds) {
    const millisecondsPerFrame = 200;
    spriteIndex = (milliseconds / millisecondsPerFrame).floor() % maxFrames;
  }

  @override
  void render(Canvas canvas, Size size) {
    canvas.drawImageRect(
      AssetsData.player,
      Rect.fromLTWH(
        spriteIndex * width,
        0,
        width,
        height,
      ),
      Rect.fromLTWH(
        size.width / 2 - resize.width / 2,
        size.height - resize.height,
        resize.width,
        resize.height,
      ),
      Paint(),
    );
  }

  void moveLeft() {
    if (x > -1) {
      x -= 0.5;
    }
  }

  void moveRight() {
    if (x < 1) {
      x += 0.5;
    }
  }

  void acelerate() {
    speed = maxSpeed;
    // if (speed < maxSpeed) {
    //   speed += aceleration;
    // }
  }

  void decelerate() {
    if (speed > 0) {
      speed -= deceleration;
    }
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

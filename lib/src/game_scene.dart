import 'package:flutter/material.dart';
import 'package:flutter_fake_racer/src/components/player.dart';
import 'package:flutter_fake_racer/src/data/constants.dart';

import 'components/road.dart';
import 'types/frame_time.dart';

class GameScene extends CustomPainter {
  final FrameTime time;
  final GameState state;

  final Road road;
  final Player player;

  GameScene({
    required this.time,
    required this.state,
    required this.road,
    required this.player,
  });

  @override
  void paint(Canvas canvas, Size size) {
    /* background sky */
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.blue,
    );

    /* draw coomponents */
    if (state.isPlaying) {
      road.render(canvas, size);
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return oldDelegate != this;
  }
}

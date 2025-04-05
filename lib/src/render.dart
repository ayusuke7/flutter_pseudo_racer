import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_fake_racer/src/components/player.dart';
import 'package:flutter_fake_racer/src/data/assets.dart';
import 'package:flutter_fake_racer/src/data/constants.dart';

import 'components/road.dart';
import 'types/frame_time.dart';

class Render extends CustomPainter {
  final FrameTime time;
  final GameState state;

  final Road road;
  final Player player;

  final bool debug;

  Render({
    required this.time,
    required this.state,
    required this.road,
    required this.player,
    this.debug = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    /* background sky */
    canvas.drawImageRect(
      AssetsData.skyClear,
      Rect.fromLTWH(0, 0, size.width, size.height),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    /* draw coomponents */
    if (state.isPlaying) {
      road.render(canvas, size);
      player.render(canvas, size);
    }

    /* draw debug info */
    if (debug) {
      canvas.drawParagraph(
        _createParagraph(),
        Offset(10, 10),
      );
    }
  }

  Paragraph _createParagraph() {
    final builder = ParagraphBuilder(ParagraphStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ));
    builder.pushStyle(
      TextStyle(
        color: Colors.black,
      ).getTextStyle(),
    );
    builder.addText('$time\n$player\n$road');
    return builder.build()
      ..layout(
        const ParagraphConstraints(
          width: double.maxFinite,
        ),
      );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return oldDelegate != this;
  }
}

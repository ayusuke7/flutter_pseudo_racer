import 'dart:ui';

import 'package:flutter_fake_racer/src/components/player.dart';

import '../components/camera.dart';
import '../types/segment.dart';
import '../types/vector.dart';
import 'component.dart';

class Road extends Component {
  late Camera camera;
  late Player player;

  List<Segment> segments = [];

  int segmentCount;
  int segmentRumble;
  int segmentVisible;
  int segmentLength;

  int roadLength;
  int roadWidth;
  int roadLanes;

  Road({
    this.segmentLength = 100,
    this.roadWidth = 1000,
    this.roadLength = 0,
    this.segmentCount = 0,
    this.segmentVisible = 200,
    this.segmentRumble = 5,
    this.roadLanes = 3,
  });

  void init() {
    segments = [];

    for (var i = 0; i < 300; i++) {
      _createSegment();
    }

    for (var i = 0; i < segmentRumble; i++) {
      segments[i].colors.road = Color(0xFFFFFFFF); // start
      segments[segments.length - 1 - i].colors.road =
          Color(0xFF222222); // finish
    }

    segmentCount = segments.length;
    roadLength = segmentCount * segmentLength;
  }

  void render(Canvas canvas, Size size) {
    var clipBottomLine = size.height;

    var baseSegment = _getSegment(camera.z);
    var baseIndex = baseSegment.index;

    for (var i = 0; i < segmentVisible; i++) {
      final currentIndex = (baseIndex + i) % segmentCount;
      final currentSegment = segments[currentIndex];
      final offsetZ = currentIndex < baseIndex ? roadLength : 0;

      _projectSegment(currentSegment, offsetZ, size);

      var currentBottomLine = currentSegment.point.screen.y;

      if (i > 0 && currentBottomLine < clipBottomLine) {
        final previousIndex = currentIndex > 0 ? currentIndex : segmentCount;
        final previousSegment = segments[previousIndex - 1];

        _drawSegment(
          canvas,
          size,
          previousSegment,
          currentSegment,
        );

        clipBottomLine = currentBottomLine;
      }
    }
  }

  void _projectSegment(Segment segment, int offsetZ, Size size) {
    final tranX = segment.point.world.x - camera.x;
    final tranY = segment.point.world.y - camera.y;
    final tranZ = segment.point.world.z - (camera.z - offsetZ);

    segment.point.scale = camera.distToPlane / tranZ;

    final projectedX = segment.point.scale * tranX;
    final projectedY = segment.point.scale * tranY;
    final projectedW = segment.point.scale * roadWidth;

    segment.point.screen = Vector(
      x: ((1 + projectedX) * size.width / 2).roundToDouble(),
      y: ((1 - projectedY) * size.height / 2).roundToDouble(),
      w: (projectedW * size.width / 2).roundToDouble(),
    );
  }

  void _createSegment() {
    final n = segments.length;
    final z = (n * segmentLength).toDouble();
    final dark = (n / segmentRumble).floor() % 2 > 0;

    segments.add(
      Segment(
        index: n,
        point: SegPoint(
          screen: Vector(x: 0, y: 0, w: 0),
          world: Vector(x: 0, y: 0, z: z),
          scale: -1,
        ),
        colors: SegColor(
          road: dark ? Color(0xFF666666) : Color(0xFF888888),
          grass: dark ? Color(0xFF397d46) : Color(0xFF429352),
          rumble: dark ? Color(0xFFDDDDDD) : Color(0xFFb8312e),
          lane: dark ? Color(0xFFFFFFFF) : null,
        ),
      ),
    );
  }

  void _drawSegment(
    Canvas canvas,
    Size size,
    Segment previous,
    Segment current,
  ) {
    final p1 = previous.point.screen;
    final p2 = current.point.screen;

    // draw grass
    canvas.drawRect(
      Rect.fromLTWH(0, p2.y, size.width, p1.y - p2.y),
      Paint()..color = current.colors.grass,
    );

    // draw road
    _drawPolygon(
      canvas,
      p1.x - p1.w,
      p1.y,
      p1.x + p1.w,
      p1.y,
      p2.x + p2.w,
      p2.y,
      p2.x - p2.w,
      p2.y,
      current.colors.road,
    );

    // draw rumble strips
    final rumbleW1 = p1.w / 5;
    final rumbleW2 = p2.w / 5;

    _drawPolygon(
      canvas,
      p1.x - p1.w - rumbleW1,
      p1.y,
      p1.x - p1.w,
      p1.y,
      p2.x - p2.w,
      p2.y,
      p2.x - p2.w - rumbleW2,
      p2.y,
      current.colors.rumble,
    );
    _drawPolygon(
      canvas,
      p1.x + p1.w + rumbleW1,
      p1.y,
      p1.x + p1.w,
      p1.y,
      p2.x + p2.w,
      p2.y,
      p2.x + p2.w + rumbleW2,
      p2.y,
      current.colors.rumble,
    );

    // draw lanes
    if (current.colors.lane != null) {
      final lineW1 = (p1.w / 20) / 2;
      final lineW2 = (p2.w / 20) / 2;

      final laneW1 = (p1.w * 2) / roadLanes;
      final laneW2 = (p2.w * 2) / roadLanes;

      var laneX1 = p1.x - p1.w;
      var laneX2 = p2.x - p2.w;

      for (var i = 1; i < roadLanes; i++) {
        laneX1 += laneW1;
        laneX2 += laneW2;

        _drawPolygon(
          canvas,
          laneX1 - lineW1,
          p1.y,
          laneX1 + lineW1,
          p1.y,
          laneX2 + lineW2,
          p2.y,
          laneX2 - lineW2,
          p2.y,
          current.colors.lane!,
        );
      }
    }
  }

  void _drawPolygon(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
    double x4,
    double y4,
    Color color,
  ) {
    canvas.drawPath(
      Path()
        ..moveTo(x1, y1)
        ..lineTo(x2, y2)
        ..lineTo(x3, y3)
        ..lineTo(x4, y4)
        ..close(),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  Segment _getSegment(double positionZ) {
    if (positionZ < 0) positionZ += roadLength;

    final index = (positionZ / segmentLength).floor() % segmentCount;
    return segments[index];
  }
}

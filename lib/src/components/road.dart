import 'dart:ui';

import '../types/segment.dart';
import '../types/vector.dart';
import 'component.dart';
import 'player.dart';

class Road extends Component {
  late Player player;

  List<Segment> segments = [];

  int segmentCount;
  int segmentRumble;
  int segmentVisible;
  int segmentLength;
  int roadWidth;

  int roadLength = 0;

  Road({
    this.roadWidth = 1000,
    this.segmentCount = 0,
    this.segmentRumble = 5,
    this.segmentLength = 100,
    this.segmentVisible = 200,
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

  @override
  void render(Canvas canvas, Size size) {
    var clipBottomLine = size.height - 10;

    var baseSegment = _getSegment(player.cameraPosition.z);
    var baseIndex = baseSegment.index;

    for (var i = 0; i < segmentVisible; i++) {
      final currentIndex = (baseIndex + i) % segmentCount;
      final currentSegment = segments[currentIndex];
      final offsetZ = currentIndex < baseIndex ? roadLength : 0;

      _projectSegment(currentSegment, offsetZ, size);

      final currentBottomLine = currentSegment.point.screen.y;
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
    final tranX = segment.point.world.x - player.cameraPosition.x;
    final tranY = segment.point.world.y - player.cameraPosition.y;
    final tranZ = segment.point.world.z - (player.cameraPosition.z - offsetZ);

    segment.point.scale = player.distToPlane / tranZ;

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

    // draw rumble
    _drawRumble(
      canvas,
      previous,
      current,
    );

    // draw lanes
    _drawLanes(
      canvas,
      previous,
      current,
    );
  }

  void _drawRumble(
    Canvas canvas,
    Segment previous,
    Segment current,
  ) {
    final p1 = previous.point.screen;
    final p2 = current.point.screen;

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
  }

  void _drawLanes(
    Canvas canvas,
    Segment previous,
    Segment current,
  ) {
    if (current.colors.lane == null) return;

    final p1 = previous.point.screen;
    final p2 = current.point.screen;

    final lineW1 = (p1.w / 20) / 2;
    final lineW2 = (p2.w / 20) / 2;

    final laneW1 = (p1.w * 2) / 3;
    final laneW2 = (p2.w * 2) / 3;

    var laneX1 = p1.x - p1.w;
    var laneX2 = p2.x - p2.w;

    for (var i = 1; i < 3; i++) {
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
    canvas.save();
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
    canvas.restore();
  }

  Segment _getSegment(double positionZ) {
    if (positionZ < 0) positionZ += roadLength;

    final index = (positionZ / segmentLength).floor() % segmentCount;
    return segments[index];
  }

  @override
  String toString() {
    return 'Road = segments $segmentCount / width $roadWidth / length $roadLength';
  }
}

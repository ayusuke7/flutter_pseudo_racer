import '../types/frame_time.dart';
import 'component.dart';
import 'player.dart';
import 'road.dart';

class Camera extends Component {
  late Road road;
  late Player player;

  double distToPlane;
  double distToPlayer;

  Camera({
    super.x = 0,
    super.y = 1000,
    super.z = 0,
    this.distToPlane = 100,
    this.distToPlayer = 500,
  });

  void init() {
    distToPlane = 1 / (y / distToPlayer);
  }

  void update(FrameTime time) {
    x = player.x * road.roadWidth;
    z = player.z - distToPlayer;

    if (z < 0) z += road.roadLength;
  }
}

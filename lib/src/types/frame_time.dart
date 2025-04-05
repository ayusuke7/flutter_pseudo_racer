class FrameTime {
  int previous;
  double delta;

  FrameTime(
    this.previous,
    this.delta,
  );

  int get fps => delta > 0 ? 1 ~/ delta : 0;

  int get seconds => previous ~/ 1000;

  @override
  String toString() {
    return 'Time = FPS $fps / ${seconds}s';
  }
}

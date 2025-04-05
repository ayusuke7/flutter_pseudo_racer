import 'dart:ui';

const Size gameSize = Size(720, 480);

enum GameState {
  init,
  play,
  pause,
  restart,
  gameover;

  int get value => index + 1;

  bool get isPlaying => this == play;
}

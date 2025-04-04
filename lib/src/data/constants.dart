const double screenWidth = 720;
const double screenHeight = 480;

enum GameState {
  init,
  play,
  pause,
  restart,
  gameover;

  int get value => index + 1;

  bool get isPlaying => this == play;
}

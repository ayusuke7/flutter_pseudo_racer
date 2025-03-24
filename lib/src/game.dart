import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'components/camera.dart';
import 'components/player.dart';
import 'components/road.dart';
import 'data/constants.dart';
import 'game_scene.dart';
import 'types/frame_time.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final _time = FrameTime(0, 0);
  final _road = Road();
  final _camera = Camera();
  final _player = Player();

  GameState _state = GameState.init;

  void _init() {
    _camera.player = _player;
    _camera.road = _road;

    _player.camera = _camera;
    _player.road = _road;

    _road.camera = _camera;
    _road.player = _player;

    SchedulerBinding.instance.scheduleFrameCallback(_loop);
  }

  void _loop(Duration timeStamp) {
    SchedulerBinding.instance.scheduleFrameCallback(_loop);
    int currentTime = timeStamp.inMilliseconds;

    _time.secondsPassed = (currentTime - _time.previous) / 1000.0;
    _time.previous = currentTime;

    _update();
    setState(() {});
  }

  void _update() {
    switch (_state) {
      case GameState.init:
        _camera.init();
        _player.init();
        _state = GameState.restart;
        break;
      case GameState.play:
        _player.update(_time);
        _camera.update(_time);
        break;
      case GameState.restart:
        _road.init();
        _player.reset();
        _state = GameState.play;
        break;
      case GameState.gameover:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          autofocus: true,
          onKeyEvent: _keyEventHandler,
          child: Stack(
            children: [
              Center(
                child: CustomPaint(
                  size: Size(
                    screenWidth,
                    screenHeight,
                  ),
                  painter: GameScene(
                    player: _player,
                    state: _state,
                    road: _road,
                    time: _time,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Camera: ${_camera.z}\nRoad: ${_road.roadLength}\nSpeed: ${_player.speed}\n',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  KeyEventResult _keyEventHandler(FocusNode node, KeyEvent event) {
    final pressed = HardwareKeyboard.instance.isLogicalKeyPressed(
      event.logicalKey,
    );

    if (!pressed) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      // _player.speed = _player.aceleration;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // _player.speed = _player.deceleration;
    }

    return KeyEventResult.handled;
  }
}

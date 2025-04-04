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

    _time.delta = (currentTime - _time.previous) / 1000.0;
    _time.previous = currentTime;

    _update();
    setState(() {});
  }

  void _update() {
    switch (_state) {
      case GameState.init:
        _road.init();
        _camera.init();
        _state = GameState.play;
        break;
      case GameState.play:
        _camera.update(_time);
        _player.update(_time);
        break;
      case GameState.restart:
        _player.reset();
        break;
      case GameState.pause:
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
        body: Center(
          child: ColoredBox(
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Focus(
                  autofocus: true,
                  onKeyEvent: _keyEventHandler,
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
                Column(
                  children: [
                    _time.toString(),
                    _player.toString(),
                    _camera.toString(),
                    _road.toString(),
                  ]
                      .map((text) => Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _keyEventHandler(FocusNode node, KeyEvent event) {
    final pressed = HardwareKeyboard.instance.isLogicalKeyPressed(
      event.logicalKey,
    );

    if (pressed && event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _player.acelerate();
    } else {
      _player.decelerate();
    }

    return KeyEventResult.handled;
  }
}

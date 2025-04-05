import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'components/player.dart';
import 'components/road.dart';
import 'data/constants.dart';
import 'render.dart';
import 'types/frame_time.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final _time = FrameTime(0, 0);
  final _player = Player();
  final _road = Road();

  GameState _state = GameState.init;

  void _init() {
    _player.road = _road;
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
        _player.init();
        _state = GameState.play;
        break;
      case GameState.play:
        _player.update(_time);
        break;
      case GameState.restart:
        _player.reset();
        break;
      case GameState.pause:
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
          child: Center(
            child: CustomPaint(
              size: gameSize,
              painter: Render(
                player: _player,
                state: _state,
                road: _road,
                time: _time,
                debug: true,
              ),
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

    if (pressed) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          _player.acelerate();
          break;
        case LogicalKeyboardKey.arrowDown:
          _player.stop();
          break;
        case LogicalKeyboardKey.arrowLeft:
          _player.moveLeft();
          break;
        case LogicalKeyboardKey.arrowRight:
          _player.moveRight();
          break;
        default:
          break;
      }
    }

    return KeyEventResult.handled;
  }
}

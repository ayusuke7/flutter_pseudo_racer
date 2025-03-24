import 'package:flutter/material.dart';

import 'src/data/assets.dart';
import 'src/game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AssetsData.loadImages();
  runApp(const Game());
}

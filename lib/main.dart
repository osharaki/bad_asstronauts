import 'package:flame/extensions/vector2.dart';
import "package:flame/util.dart";
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:bad_asstronauts/gameLauncher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setLandscape();
  await SystemChrome.setEnabledSystemUIOverlays([]);
  Vector2 viewportSize = await flameUtil.initialDimensions();

  await DotEnv().load('.env');

  runApp(GameLauncher(viewportSize));
}

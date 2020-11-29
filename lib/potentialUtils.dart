import 'package:flutter/material.dart';
import 'package:gameOff2020/gameLauncher.dart';
import 'package:gameOff2020/utils/math.dart';

GameLauncherState launcher;

Offset getWorldPositionFromPercent(List<dynamic> percent) {
  var x = mapValue(
    aValue: launcher.serverHandler, // Arena Width
    bValue: 100,
    bMatch: percent[0],
  );

  var y = mapValue(
    aValue: launcher.serverHandler, // Arena Height
    bValue: 100,
    bMatch: percent[1],
  );

  var worldPosition = Offset(x, y);

  return worldPosition;
}

List<dynamic> getPercentFromWorldPosition(Offset position) {
  var x = mapValue(
    aValue: 100,
    bValue: launcher.serverHandler, // Arena Width
    bMatch: position.dx,
  );

  var y = mapValue(
    aValue: 100,
    bValue: launcher.serverHandler, // Arena Height
    bMatch: position.dy,
  );

  List<dynamic> percent = [x, y];

  return percent;
}

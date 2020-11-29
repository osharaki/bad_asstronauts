import 'package:flutter/material.dart';
import 'package:gameOff2020/utils/math.dart';

Offset getWorldPositionFromPercent(List<dynamic> percent) {
  var x = mapValue(
    aValue: launcher.serverHandler.arena.size.width,
    bValue: 100,
    bMatch: percent[0],
  );

  var y = mapValue(
    aValue: launcher.serverHandler.arena.size.height,
    bValue: 100,
    bMatch: percent[1],
  );

  var worldPosition = Offset(x, y);

  return worldPosition;
}

List<dynamic> getPercentFromWorldPosition(Offset position) {
  var x = mapValue(
    aValue: 100,
    bValue: launcher.serverHandler.arena.size.width,
    bMatch: position.dx,
  );

  var y = mapValue(
    aValue: 100,
    bValue: launcher.serverHandler.arena.size.height,
    bMatch: position.dy,
  );

  List<dynamic> percent = [x, y];

  return percent;
}

void moveCameraToPercent(List<dynamic> percent) {
  // Position at screen top left corner
  Offset position = getWorldPositionFromPercent(percent);

  // Move position to screen center
  position = screenCenter - position;

  // Check if screen exceeds arena boundaries
  // Left
  if (position.dx > 0) position = Offset(0, position.dy);

  // Right
  if (position.dx.abs() + screenCenter.dx > launcher.serverHandler.arena.size.width)
    position =
        Offset((launcher.serverHandler.arena.size.width * -1) + screenSize.width, position.dy);

  // Top
  if (position.dy > 0) position = Offset(position.dx, 0);

  // Bottom
  if (position.dy.abs() + screenCenter.dy > launcher.serverHandler.arena.size.height)
    position =
        Offset(position.dx, (launcher.serverHandler.arena.size.height * -1) + screenSize.height);

  // Assign final position to arena
  launcher.serverHandler.arena.position = position;
}

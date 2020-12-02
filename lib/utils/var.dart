import 'dart:math';
import 'dart:ui';
import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';
import 'package:gameOff2020/utils/math.dart';

Offset convertVectorToOffset(Vector2 vector) {
  Offset offset = Offset(vector.x, vector.y);

  return offset;
}

Color blendColors({
  @required Color startColor,
  @required Color endColor,
  @required double blend,
}) {
  Color blendColor = Color.fromARGB(
    mapValueFromRangeToRange(
      aValue: blend,
      aStart: 0,
      aEnd: 1,
      bStart: startColor.alpha,
      bEnd: endColor.alpha,
    ).toInt(),
    mapValueFromRangeToRange(
      aValue: blend,
      aStart: 0,
      aEnd: 1,
      bStart: startColor.red,
      bEnd: endColor.red,
    ).toInt(),
    mapValueFromRangeToRange(
      aValue: blend,
      aStart: 0,
      aEnd: 1,
      bStart: startColor.green,
      bEnd: endColor.green,
    ).toInt(),
    mapValueFromRangeToRange(
      aValue: blend,
      aStart: 0,
      aEnd: 1,
      bStart: startColor.blue,
      bEnd: endColor.blue,
    ).toInt(),
  );

  return blendColor;
}

Vector2 normalizeVector(Vector2 vector) {
  double x = vector.x;
  double y = vector.y;

  double maxValue = max(x, y);
  double normalizeFactor = 1 / maxValue.abs();

  double xNormalize = x.abs() * normalizeFactor;
  double yNormalize = y.abs() * normalizeFactor;

  if (x.isNegative) xNormalize *= -1;
  if (y.isNegative) yNormalize *= -1;

  Vector2 vectorNormalize = Vector2(xNormalize, yNormalize);

  return vectorNormalize;
}

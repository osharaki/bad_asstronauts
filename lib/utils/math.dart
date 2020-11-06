import "dart:math";
import 'package:flutter/material.dart';

int getRandomValueInRange({
  @required int min,
  @required int max,
}) {
  var random = Random();

  int randomValue = (min + random.nextInt(max - min));

  return randomValue;
}

double mapValueFromRangeToRange({
  @required dynamic aValue,
  @required dynamic aStart,
  @required dynamic aEnd,
  @required dynamic bStart,
  @required dynamic bEnd,
}) {
  double slope = (bEnd - bStart) / (aEnd - aStart);
  double mappedValue = bStart + (slope * (aValue - aStart));

  return mappedValue;
}

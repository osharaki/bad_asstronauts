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

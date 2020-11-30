import "dart:math";
import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart';

double getDecimal(double number) {
  int wholeNumber = number.toInt();
  double decimal = number - wholeNumber;

  return decimal;
}

dynamic getRandomValueInRange({
  @required dynamic min,
  @required dynamic max,
}) {
  var random = Random();
  dynamic randomValue;

  // If Min & Max are Doubles
  if (min is double || max is double) {
    // Get Random Whole Number
    int minInt = min.floor();
    int maxInt = max.floor();

    if (minInt == maxInt) {
      randomValue = minInt.toDouble();
    } else {
      randomValue = (minInt + random.nextInt(maxInt - minInt)).toDouble();
    }

    // Get Random Decimal Number
    int minDecimalInt = 0;
    int maxDecimalInt = 9999;

    // If Min & Max share the same whole number
    if (minInt == maxInt) {
      minDecimalInt = (getDecimal(min.toDouble()) * 10000).toInt();
      maxDecimalInt = (getDecimal(max.toDouble()) * 10000).toInt();

      // If random value is Min
    } else if (randomValue == minInt) {
      minDecimalInt = 0;
      maxDecimalInt = (getDecimal(min.toDouble()) * 10000).toInt();

      // If random value is Max
    } else if (randomValue == maxInt) {
      minDecimalInt = 0;
      maxDecimalInt = (getDecimal(max.toDouble()) * 10000).toInt();
    }

    // Get random value in MinMax Decimal range
    int randomDecimalInt = getRandomValueInRange(
      min: minDecimalInt,
      max: maxDecimalInt,
    );

    // Create Real Decimal from Decimal Integer
    String randomDecimalString = "0." + randomDecimalInt.toString();
    double randomDecimal = double.parse(randomDecimalString);

    // Add Random Decimal to Random Whole
    randomValue = randomValue + randomDecimal;

    // If Min & Max are Integers
  } else {
    if (min == max) {
      randomValue = min;
    } else {
      randomValue = (min + random.nextInt(max - min));
    }
  }

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

dynamic mapValue(
    {@required dynamic aValue,
    @required dynamic bValue,
    @required dynamic bMatch}) {
  dynamic mappedValue = (aValue * bMatch) / bValue;

  return mappedValue;
}

dynamic getValueInRangeFromPercent({
  @required dynamic min,
  @required dynamic max,
  @required dynamic percent,
}) {
  dynamic range = max - min;

  dynamic value = mapValue(
        aValue: range,
        bValue: 100,
        bMatch: percent,
      ) +
      min;

  return value;
}

Vector2 getRelativeCoordinates({
  @required Vector2 reference,
  @required Vector2 global,
}) {
  double xRelative = global.x - reference.x;
  double yRelative = global.y - reference.y;
  Vector2 relative = Vector2(xRelative, yRelative);

  return relative;
}

double valueInvertAndMap({
  @required double value,
  @required double oldMax,
  @required double newMax,
  double oldMin = 0,
  double newMin = 0,
}) {
  // Invert distance to make the closer distance have a stronger pull, and vice versa
  double valueInverse = mapValueFromRangeToRange(
    aValue: value,
    aStart: oldMin,
    aEnd: oldMax,
    bStart: oldMax,
    bEnd: oldMin,
  );

  // Distribute inverted distance to a bigger range, so we have more constrast between the pull forces
  double valueConvert = mapValueFromRangeToRange(
    aValue: valueInverse,
    aStart: oldMin,
    aEnd: oldMax,
    bStart: newMin,
    bEnd: newMax,
  );

  return valueConvert;
}

dynamic clampValueToRange(
    {@required dynamic value, @required dynamic min, @required dynamic max}) {
  dynamic clampedValue = value;

  if (value < min) {
    clampedValue = min;
  } else if (value > max) {
    clampedValue = max;
  }

  return clampedValue;
}

import "dart:math";
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

import 'dart:ui';
import 'package:flame/extensions/vector2.dart';

Offset convertVectorToOffset(Vector2 vector) {
  Offset offset = Offset(vector.x, vector.y);

  return offset;
}

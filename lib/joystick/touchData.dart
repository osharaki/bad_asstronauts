import "package:flutter/gestures.dart";

class TouchData {
  final int touchId;
  final Offset offset;

  TouchData(
    this.touchId,
    this.offset,
  );
}

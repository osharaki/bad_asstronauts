import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ItemDrag extends Drag {
  final Function onUpdate;
  final Function onEnd;
  final Function onCancel;
  final int touchId;

  ItemDrag(
    this.onUpdate,
    this.onEnd,
    this.onCancel,
    this.touchId,
  );

  @override
  void update(DragUpdateDetails details) {
    super.update(details);
    onUpdate(details, touchId);
  }

  @override
  void end(DragEndDetails details) {
    super.end(details);
    onEnd(details, touchId);
  }

  @override
  void cancel() {
    super.cancel();
    onCancel(touchId);
  }
}

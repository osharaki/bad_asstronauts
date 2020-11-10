import 'package:flutter/material.dart';

class Server {
  Map<String, List<dynamic>> components = Map();

  void update(double t) {
    components.forEach((category, items) {
      items.forEach((item) {
        item.update(t);
      });
    });
  }

  void render(Canvas canvas) {
    components.forEach((category, items) {
      items.forEach((item) {
        item.render(canvas);
      });
    });
  }
}

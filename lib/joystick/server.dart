import 'package:flutter/material.dart';

class Server {
  List<dynamic> components;

  void update(double t) {
    components.forEach((item) {
      item.update(t);
    });
  }

  void render(Canvas canvas) {
    components.forEach((item) {
      item.render(canvas);
    });
  }
}

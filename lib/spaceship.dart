import 'package:flame/components/component.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite.dart';

class Spaceship extends SpriteComponent implements JoystickListener {
  Spaceship(Sprite sprite, Vector2 size) : super.fromSprite(size, sprite);

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) {
      if (event.id == 1) {
        print('event.id == 1');
      }
      if (event.id == 2) {
        print('event.id == 2');
      }
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    // TODO: implement joystickChangeDirectional
  }
}

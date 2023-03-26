import '../enum/drawer_state.dart';

mixin DrawerMoveController {
  void move(bool open);

  void open() => move(true);

  void close() => move(false);

  /// getter of the now drawer state.
  DrawerState get nowState;
}

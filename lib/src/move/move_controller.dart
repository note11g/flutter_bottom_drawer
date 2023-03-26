import '../enum/drawer_state.dart';

mixin DrawerMoveController {
  /// open or close drawer.
  /// `move(true)` is same as `open()`.
  /// `move(false)` is same as `close()`.
  void move(bool open);

  /// open drawer.
  void open() => move(true);

  /// close drawer.
  void close() => move(false);

  /// getter of the now drawer state.
  DrawerState get nowState;
}

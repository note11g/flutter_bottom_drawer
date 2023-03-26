import '../enum/drawer_state.dart';

/// Moving Controller of the drawer.
/// You can use this to open or close the drawer.
mixin DrawerMoveController {
  /// open or close drawer.
  /// `move(true)` is same as `open()`.
  /// `move(false)` is same as `close()`.
  void move(bool open);

  /// auto open or close drawer.
  /// if the drawer is opened, close it.
  /// if the drawer is closed, open it.
  void autoMove() => nowState.when(closed: open, opened: close);

  /// open drawer.
  void open() => move(true);

  /// close drawer.
  void close() => move(false);

  /// getter of the now drawer state.
  DrawerState get nowState;
}

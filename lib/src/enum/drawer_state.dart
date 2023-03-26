/// State of [BottomDrawer].
enum DrawerState {
  /// Drawer is fully opened.
  opened,

  /// Drawer is fully closed. (first state)
  closed,

  /// Drawer is now opening.
  opening,

  /// Drawer is now closing.
  closing;

  /// [BottomDrawer.height] is...
  /// null : Expand only when canExpanded.
  /// defined : Expand all time.
  bool get canExpanded =>
      this == DrawerState.opened ||
      this == DrawerState.opening ||
      this == DrawerState.closing;

  /// Drawer is running (opening or closing).
  bool get isRunning =>
      this == DrawerState.opening || this == DrawerState.closing;

  /// Drawer is finished (opened or closed).
  bool get isFinished =>
      this == DrawerState.opened || this == DrawerState.closed;

  DrawerState get nextFinishState {
    assert(isRunning);
    if (this == DrawerState.opening) return DrawerState.opened;
    return DrawerState.closed;
  }

  void when({
    Function()? opened,
    Function()? closed,
    Function()? opening,
    Function()? closing,
  }) {
    switch (this) {
      case DrawerState.opened:
        opened?.call();
        break;
      case DrawerState.closed:
        closed?.call();
        break;
      case DrawerState.opening:
        opening?.call();
        break;
      case DrawerState.closing:
        closing?.call();
        break;
    }
  }

  static DrawerState getRunningState({required bool isOpening}) {
    return isOpening ? DrawerState.opening : DrawerState.closing;
  }
}

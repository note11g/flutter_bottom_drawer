enum DrawerState {
  needUpdate,
  opened,
  closed,
  opening,
  closing;

  bool get canExpanded =>
      this == DrawerState.opened ||
      this == DrawerState.opening ||
      this == DrawerState.closing;

  bool get isRunning =>
      this == DrawerState.opening || this == DrawerState.closing;

  bool get isFinished =>
      this == DrawerState.opened || this == DrawerState.closed;

  DrawerState get nextFinishState {
    assert(isRunning);
    if (this == DrawerState.opening) return DrawerState.opened;
    return DrawerState.closed;
  }

  void when({
    Function()? needUpdate,
    Function()? opened,
    Function()? closed,
    Function()? opening,
    Function()? closing,
  }) {
    switch (this) {
      case DrawerState.needUpdate:
        needUpdate?.call();
        break;
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

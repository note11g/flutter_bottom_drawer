part of flutter_bottom_drawer;

enum DrawerState {
  noHeight,
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

  bool get _needHeightUpdate => this == DrawerState.noHeight;

  DrawerState get nextRunningState {
    if (this == DrawerState.closed) return DrawerState.opening;
    return DrawerState.closing;
  }

  DrawerState get nextFinishState {
    assert(isRunning);
    if (this == DrawerState.opening) return DrawerState.opened;
    return DrawerState.closed;
  }

  static DrawerState getRunningState(bool open) {
    return open ? DrawerState.opening : DrawerState.closing;
  }

  static DrawerState getFinishState(bool open) {
    return open ? DrawerState.opened : DrawerState.closed;
  }
}

enum _Direction {
  up,
  down,
  none;

  bool get isUp => this == _Direction.up;
  bool get isDown => this == _Direction.down;
  bool get isNone => this == _Direction.none;
}

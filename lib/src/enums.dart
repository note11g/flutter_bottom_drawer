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

  DrawerState get nextFinishState {
    assert(isRunning);
    if (this == DrawerState.opening) return DrawerState.opened;
    return DrawerState.closed;
  }

  static DrawerState getRunningState({required bool isOpening}) {
    return isOpening ? DrawerState.opening : DrawerState.closing;
  }

  static DrawerState getFinishState({required bool isOpened}) {
    return isOpened ? DrawerState.opened : DrawerState.closed;
  }
}

enum _Direction {
  up,
  down,
  none;

  bool get isUp => this == _Direction.up;

  bool get isDown => this == _Direction.down;

  bool get isNone => this == _Direction.none;

  static _Direction fromDragDelta(double deltaY) {
    if (deltaY == 0) return _Direction.none;
    return deltaY < 0 ? _Direction.up : _Direction.down;
  }
}

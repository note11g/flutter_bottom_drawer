enum Direction {
  up,
  down,
  none;

  bool get isUp => this == Direction.up;

  bool get isDown => this == Direction.down;

  bool get isNone => this == Direction.none;

  static Direction fromDragDelta(double deltaY) {
    if (deltaY == 0) return Direction.none;
    return deltaY < 0 ? Direction.up : Direction.down;
  }
}

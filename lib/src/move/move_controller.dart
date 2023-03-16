mixin DrawerMoveController {
  void move(bool open);

  void open() => move(true);

  void close() => move(false);
}

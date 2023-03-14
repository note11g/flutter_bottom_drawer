part of flutter_bottom_drawer;

class _MoveHandler {
  final void Function() rebuild;

  final StateController stateController;

  _MoveHandler({
    required this.rebuild,
    required this.stateController,
  });

  void onDragStart(DragStartDetails details) {
    stateController.prepareAutoMove();
    rebuild();
  }

  void onDrag(DragUpdateDetails details) {
    final deltaY = details.delta.dy;
    final requestHeight = stateController.nowHeight - deltaY;
    final direction = Direction.fromDragDelta(deltaY);

    if (stateController.canManualMove(requestHeight, direction)) {
      stateController.manualMove(height: requestHeight, direction: direction);
      rebuild();
    }
  }

  void onDragEnd(DragEndDetails details) {
    if (stateController.drawerState.isFinished) return;

    stateController.drawerState.when(
      opening: () => move(true),
      closing: () => move(false),
    );

    rebuild();
  }

  void move(bool open) {
    stateController.requestAutoMove(open: open);
    rebuild();
  }

  void onAnimationEnd() {
    if (stateController.drawerState.isFinished) return;

    if (stateController.isRequestedMove) {
      stateController.finishMove();
      rebuild();
    }
  }
}

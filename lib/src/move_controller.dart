part of flutter_bottom_drawer;

class _MoveController {
  final void Function() rebuild;

  final StateController stateController;

  _MoveController({
    required this.rebuild,
    required this.stateController,
  });

  void onDragStart(DragStartDetails details) {
    stateController.disableAnimation();
    rebuild();
  }

  void onDrag(DragUpdateDetails details) {
    final deltaY = details.delta.dy;
    final requestHeight = stateController.nowHeight - deltaY;
    final direction = Direction.fromDragDelta(deltaY);

    stateController.dragUpdateWhenNeedUpdate(
      height: requestHeight,
      direction: direction,
      onUpdated: rebuild,
    );
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
    stateController.prepareMove(open: open);
    rebuild();
  }

  void onAnimationEnd() {
    if (stateController.drawerState.isFinished) return;

    if (isDragEnded) {
      stateController.finishedState();
      rebuild();
    }
  }

  /// 아직 드래그가 끝나지 않은 경우면, animation은 disabled 되어있다.
  bool get isDragEnded => stateController.animationEnabled;
}

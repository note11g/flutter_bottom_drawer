part of flutter_bottom_drawer;

class _MoveController {
  final void Function() rebuild;
  final void Function(Function() callback) runAfterBuild;

  final double Function() getNowHeight;
  final DrawerState Function() getMoveState;
  final void Function(double) changeHeight;
  final void Function(DrawerState) changeMoveState;
  final void Function(bool) useAnimation;

  final bool Function(double) isValidHeight;
  final double Function(bool) expectHeight;

  double get nowHeight => getNowHeight();

  DrawerState get moveState => getMoveState();

  _MoveController({
    required this.rebuild,
    required this.runAfterBuild,
    required this.getNowHeight,
    required this.getMoveState,
    required this.changeHeight,
    required this.changeMoveState,
    required this.useAnimation,
    required this.isValidHeight,
    required this.expectHeight,
  });

  /// used on _move, _onAnimationEnd
  bool controlWithMoveMethod = false;

  /// used on _onDrag, _onDragEnd
  late _Direction direction;

  /// used on _onDrag, _onDragEnd, _onAnimationEnd
  bool animationExecuted = false;

  /// used on _onDragEnd, _onAnimationEnd, _prepareNotifyFinishState
  bool? willOpen;

  void onDragStart(DragStartDetails details) {
    useAnimation(false);
    rebuild();
  }

  void onDrag(DragUpdateDetails details) {
    final deltaY = details.delta.dy;
    final requestHeight = nowHeight - deltaY;

    direction = _Direction.fromDragDelta(deltaY);

    if (requestHeight != nowHeight && isValidHeight(requestHeight)) {
      animationExecuted = true;
      changeHeight(requestHeight);

      if (!direction.isNone) {
        final state = DrawerState.getRunningState(isOpening: direction.isUp);
        changeMoveState(state);
      }

      rebuild();
    }
  }

  void onDragEnd(DragEndDetails details) {
    willOpen = direction.willOpen(nowState: moveState);

    final expectedHeight = expectHeight(willOpen!);
    changeHeight(expectedHeight);
    useAnimation(true);

    if (!animationExecuted) _prepareNotifyFinishState();

    rebuild();
  }

  void onAnimationEnd() {
    if (controlWithMoveMethod) {
      changeMoveState(moveState.nextFinishState);
      controlWithMoveMethod = false;
      rebuild();
    } else if (willOpen != null) {
      animationExecuted = false;
      _prepareNotifyFinishState();
      runAfterBuild(() => rebuild());
    }
  }

  void _prepareNotifyFinishState() {
    final moveState = DrawerState.getFinishState(isOpened: willOpen!);
    changeMoveState(moveState);
    willOpen = null;
  }

  void move(bool open) {
    final expectedHeight = expectHeight(open);
    changeHeight(expectedHeight);

    final moveState = DrawerState.getFinishState(isOpened: open);
    changeMoveState(moveState);

    useAnimation(true);
    controlWithMoveMethod = true;
    rebuild();
  }
}

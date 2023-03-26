import 'package:flutter/material.dart';

import '../enum/direction.dart';
import '../enum/drawer_state.dart';
import '../state/state_controller.dart';
import 'move_controller.dart';

class MoveHandler with DrawerMoveController {
  final void Function() rebuild;

  final StateController stateController;

  MoveHandler({
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

  @override
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

  @override
  DrawerState get nowState => stateController.drawerState;
}

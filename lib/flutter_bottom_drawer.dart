library flutter_bottom_drawer;

import 'package:flutter/material.dart';

import 'src/enum/direction.dart';
import 'src/state_controller.dart';
import 'src/measure_util.dart';
import 'src/enum/drawer_state.dart';
export 'src/enum/drawer_state.dart';

part 'src/move_controller.dart';

class BottomDrawer extends StatefulWidget {
  final double? height;
  final double expandedHeight;
  final Color backgroundColor;
  final Color handleColor;
  final List<BoxShadow>? shadows;
  final double handleSectionHeight;
  final Size handleSize;
  final double cornerRadius;

  final bool autoResizingAnimation;
  final Duration resizeAnimationDuration;

  final void Function(double height)? onHeightChanged;
  final void Function(DrawerState state)? onStateChanged;

  final Widget Function(DrawerState state, void Function(bool open) move,
      void Function(void Function()) setState) builder;

  const BottomDrawer({
    Key? key,
    this.height,
    required this.expandedHeight,
    this.backgroundColor = Colors.white,
    this.handleColor = const Color(0xFFE0E0E0),
    this.shadows = const [defaultShadow],
    this.handleSectionHeight = 28,
    this.handleSize = const Size(40, 4),
    this.cornerRadius = 8,
    this.autoResizingAnimation = false,
    this.resizeAnimationDuration = const Duration(milliseconds: 300),
    this.onHeightChanged,
    this.onStateChanged,
    required this.builder,
  }) : super(key: key);

  @override
  State<BottomDrawer> createState() => _BottomDrawerState();

  static const defaultShadow =
      BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black26);
}

class _BottomDrawerState extends State<BottomDrawer> {
  _BottomDrawerState() {
    controller = StateController(
      getHeight: () => widget.height,
      getExpandedHeight: () => widget.expandedHeight,
      measureDrawerHeight: _measureDrawerHeight,
    );

    moveController = _MoveController(
      rebuild: _rebuild,
      stateController: controller,
    );
  }

  late final StateController controller;
  late final _MoveController moveController;

  @override
  Widget build(BuildContext context) {
    if (controller.drawerState == DrawerState.needUpdate) {
      controller.updateHeight();

      if (!widget.autoResizingAnimation) tempDisableAutoResizeAnimation();
    }

    changeWithNotifyStateAndHeight();

    return _makeDrawer();
  }

  void tempDisableAutoResizeAnimation() {
    controller.disableAnimation();
    _runAfterBuild(() => controller.enableAnimation());
  }

  double lastHeight = 0;
  DrawerState lastMoveState = DrawerState.needUpdate;

  void changeWithNotifyStateAndHeight() {
    if (lastMoveState != controller.drawerState) {
      lastMoveState = controller.drawerState;
      _notifyChanged(
          value: controller.drawerState, notifyFunc: widget.onStateChanged);
    }

    if (lastHeight != controller.nowHeight) {
      lastHeight = controller.nowHeight;
      _notifyChanged(
          value: controller.nowHeight, notifyFunc: widget.onHeightChanged);
    }
  }

  /* ----- widget maker ----- */

  Widget _makeDrawer() =>
      Positioned.fill(top: null, child: _makeGestureDetector());

  Widget _makeGestureDetector() => GestureDetector(
        onTap: () {
          /* ignore event */
        },
        onVerticalDragStart: moveController.onDragStart,
        onVerticalDragEnd: moveController.onDragEnd,
        onVerticalDragUpdate: moveController.onDrag,
        child: _makeAnimatedContainer(),
      );

  Widget _makeAnimatedContainer() => AnimatedContainer(
        onEnd: moveController.onAnimationEnd,
        height: controller.nowHeight,
        duration: controller.animationEnabled
            ? widget.resizeAnimationDuration
            : Duration.zero,
        curve: Curves.ease,
        child: _makeDecoratedContainer(),
      );

  Widget _makeDecoratedContainer() {
    final decoration = BoxDecoration(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(widget.cornerRadius)),
      color: widget.backgroundColor,
      boxShadow: widget.shadows,
    );

    return Container(
        decoration: decoration,
        child: Column(children: [_makeHandleSection(), _makeBodySection()]));
  }

  Widget _makeHandleSection() => Container(
      width: double.infinity,
      height: widget.handleSectionHeight,
      alignment: Alignment.center,
      child: Container(
        width: widget.handleSize.width,
        height: widget.handleSize.height,
        decoration: BoxDecoration(
            color: widget.handleColor,
            borderRadius: BorderRadius.circular(1000)),
      ));

  Widget _makeBodySection() {
    final needExpand =
        controller.drawerState.canExpanded ? true : isDefinedHeight;
    return Expanded(
        flex: needExpand ? 1 : 0,
        child: Material(
            color: Colors.transparent,
            child: widget.builder(
                controller.drawerState, moveController.move, _setState)));
  }

  bool get isDefinedHeight => widget.height != null;

  /* ----- widget maker end ----- */

  void _setState(void Function() func) {
    controller.notifyUpdatedNeeded();
    setState(func);
  }

  static void _runAfterBuild(Function() callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  void _rebuild() => setState(() {});

  static void _notifyChanged<T>({
    required T value,
    required Function(T)? notifyFunc,
  }) {
    if (notifyFunc != null) _runAfterBuild(() => notifyFunc.call(value));
  }

  double _measureDrawerHeight() {
    func1(bool b) {}
    func2(void Function() f) {}
    final bodyHeight = measureWidgetHeight(
        widget.builder(DrawerState.closed, func1, func2),
        context: context);
    return bodyHeight + widget.handleSectionHeight;
  }
}

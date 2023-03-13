library flutter_bottom_drawer;

import 'package:flutter/material.dart';
import 'package:flutter_bottom_drawer/src/measure_util.dart';

part 'src/enums.dart';

part 'src/move_controller.dart';

part 'src/height_controller.dart';

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
    moveController = _MoveController(
      rebuild: _rebuild,
      runAfterBuild: _runAfterBuild,
      getNowHeight: () => nowHeight,
      getMoveState: () => moveState,
      changeHeight: (height) => nowHeight = height,
      changeMoveState: (state) => moveState = state,
      useAnimation: (value) => animation = value,
      expectHeight: _expectHeight,
      isValidHeight: _isValidHeight,
    );
  }

  late double nowHeight, minHeight;

  DrawerState moveState = DrawerState.needUpdate;
  bool animation = true;

  double lastHeight = 0;
  DrawerState lastMoveState = DrawerState.needUpdate;

  late final _MoveController moveController;

  @override
  Widget build(BuildContext context) {
    if (moveState == DrawerState.needUpdate) {
      updateHeight();

      if (!widget.autoResizingAnimation) tempDisableAutoResizeAnimation();
    }

    changeWithNotifyStateAndHeight();

    return _makeDrawer();
  }

  void updateHeight() {
    minHeight = widget.height ?? measureDrawerHeight();
    nowHeight = minHeight;
    moveState = DrawerState.closed;
  }

  double measureDrawerHeight() {
    func1(bool b) {}
    func2(void Function() f) {}
    return measureWidgetHeight(widget.builder(DrawerState.closed, func1, func2),
            context: context) +
        widget.handleSectionHeight;
  }

  void tempDisableAutoResizeAnimation() {
    animation = false;
    _runAfterBuild(() => animation = true);
  }

  void changeWithNotifyStateAndHeight() {
    if (lastMoveState != moveState) {
      lastMoveState = moveState;
      _notifyChanged(value: moveState, notifyFunc: widget.onStateChanged);
    }

    if (lastHeight != nowHeight) {
      lastHeight = nowHeight;
      _notifyChanged(value: nowHeight, notifyFunc: widget.onHeightChanged);
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
        height: nowHeight,
        duration: animation ? widget.resizeAnimationDuration : Duration.zero,
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
    final needExpand = moveState.canExpanded ? true : isDefinedHeight;
    return Expanded(
        flex: needExpand ? 1 : 0,
        child: Material(
            color: Colors.transparent,
            child: widget.builder(moveState, moveController.move, _setState)));
  }

  bool get isDefinedHeight => widget.height != null;

  /* ----- widget maker end ----- */

  void _setState(void Function() func) {
    moveState = DrawerState.needUpdate;
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

  bool _isValidHeight(double height) =>
      minHeight <= height && height <= widget.expandedHeight;

  double _expectHeight(bool willOpen) =>
      willOpen ? widget.expandedHeight : minHeight;
}

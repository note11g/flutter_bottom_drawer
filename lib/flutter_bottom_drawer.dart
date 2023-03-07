library flutter_bottom_drawer;

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bottom_drawer/src/measure_util.dart';

class BottomDrawer extends StatefulWidget {
  final double? height;
  final double expandedHeight;
  final Color backgroundColor;
  final Color handleColor;
  final List<BoxShadow>? shadows;
  final double handleSectionHeight;
  final Size handleSize;
  final double radius;

  final bool autoResizingAnimation;
  final Duration resizeAnimationDuration;

  final Widget Function(
      double height,
      DrawerState state,
      void Function(bool open) move,
      void Function(void Function()) setState) builder;

  const BottomDrawer({
    Key? key,
    this.height,
    required this.expandedHeight,
    this.backgroundColor = Colors.white,
    this.handleColor = const Color(0xFFEBEBEB),
    this.shadows = const [defaultShadow],
    this.handleSectionHeight = 28,
    this.handleSize = const Size(40, 4),
    this.radius = 8,
    this.autoResizingAnimation = false,
    this.resizeAnimationDuration = const Duration(milliseconds: 300),
    required this.builder,
  }) : super(key: key);

  @override
  State<BottomDrawer> createState() => _BottomDrawerState();

  static const defaultShadow =
      BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black26);
}

class _BottomDrawerState extends State<BottomDrawer> {
  double nowHeight = 0, minHeight = 0;
  bool animation = true;

  DrawerState moveState = DrawerState.noHeight;

  @override
  Widget build(BuildContext context) {
    if (moveState._needHeightUpdate) {
      _setHeight();

      if (!widget.autoResizingAnimation) {
        animation = false;
        _runAfterBuild(() => animation = true);
      }
    }

    return _makePositionedGestureDetector();
  }

  void _setHeight() {
    minHeight = widget.height ?? _measureDrawerHeight();
    nowHeight = minHeight;
    moveState = DrawerState.closed;
  }

  double _measureDrawerHeight() {
    func1(bool b) {}
    func2(void Function() f) {}
    return measureWidgetHeight(
            widget.builder(0, DrawerState.noHeight, func1, func2),
            context: context) +
        widget.handleSectionHeight;
  }

  /* ----- widget maker ----- */

  Widget _makePositionedGestureDetector() {
    final gestureDetector = GestureDetector(
      onTap: () {
        /* ignore event */
      },
      onVerticalDragStart: _onDragStart,
      onVerticalDragEnd: _onDragEnd,
      onVerticalDragUpdate: _onDrag,
      child: _makeAnimatedContainer(),
    );
    return Positioned(left: 0, right: 0, bottom: 0, child: gestureDetector);
  }

  Widget _makeAnimatedContainer() {
    final radius = Radius.circular(widget.radius);
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      color: widget.backgroundColor,
      boxShadow: widget.shadows,
    );

    return AnimatedContainer(
      height: nowHeight != 0 ? nowHeight : null,
      duration: animation ? widget.resizeAnimationDuration : Duration.zero,
      curve: Curves.ease,
      decoration: decoration,
      onEnd: _onAnimationEnd,
      child: Column(children: [_makeHandleSection(), _makeBodySection()]),
    );
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

  Widget _makeBodySection() => Expanded(
      flex: moveState.canExpanded ? 1 : 0,
      child: widget.builder(nowHeight, moveState, _move, _setState));

  /* ----- Events ----- */

  void _onDragStart(DragStartDetails details) {
    moveState = moveState.nextRunningState;
    animation = false;
    rebuild();
  }

  void _onDrag(DragUpdateDetails details) {
    final requestHeight = nowHeight - details.delta.dy;

    if (minHeight <= requestHeight && requestHeight <= widget.expandedHeight) {
      nowHeight = requestHeight;
      rebuild();
    }
  }

  bool? willOpen;

  void _onDragEnd(DragEndDetails details) {
    final dragDirection = _checkDragDirection(details);

    if (dragDirection == _Direction.none) {
      willOpen = moveState == DrawerState.closing;
    } else {
      willOpen = dragDirection == _Direction.up;
    }

    nowHeight = getExpectHeight(willOpen!);
    animation = true;

    rebuild();
  }

  void _onAnimationEnd() {
    if (moveWithControlMethod) {
      moveState = moveState.nextFinishState;
      moveWithControlMethod = false;
      rebuild();
    } else if (willOpen != null) {
      moveState = DrawerState.getFinishState(willOpen!);
      willOpen = null;
      _runAfterBuild(() => rebuild());
    }
  }

  double getExpectHeight(bool open) => open ? widget.expandedHeight : minHeight;

  /* ----- control methods ----- */

  bool moveWithControlMethod = false;

  void _move(bool open) {
    animation = true;
    nowHeight = getExpectHeight(open);
    moveState = DrawerState.getRunningState(open);
    moveWithControlMethod = true;
    rebuild();
  }

  void _setState(void Function() func) {
    if (widget.height == null) moveState = DrawerState.noHeight;
    func.call();
    rebuild();
  }

  /* ----- utils ----- */

  static _Direction _checkDragDirection(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.dy == 0) return _Direction.none;
    return velocity.dy < 0 ? _Direction.up : _Direction.down;
  }

  static void _runAfterBuild(Function() callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  void rebuild() => setState(() {});
}

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

enum _Direction { up, down, none }

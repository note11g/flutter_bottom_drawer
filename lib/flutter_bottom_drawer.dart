library flutter_bottom_drawer;

import 'package:flutter/material.dart';
import 'package:flutter_bottom_drawer/src/measure_util.dart';

part 'src/enums.dart';

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

  final void Function(double height)? onHeightChanged;
  final void Function(DrawerState state)? onStateChanged;

  final Widget Function(DrawerState state, void Function(bool open) move,
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
  double nowHeight = 0, minHeight = 0, lastHeight = 0;
  bool animation = true;

  DrawerState moveState = DrawerState.noHeight;
  DrawerState lastMoveState = DrawerState.noHeight;

  @override
  Widget build(BuildContext context) {
    if (moveState._needHeightUpdate) {
      _setHeight();
      if (!widget.autoResizingAnimation) _disableAutoResizeAnimation();
    }

    _changeWithNotifyStateAndHeight();

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
            widget.builder(DrawerState.noHeight, func1, func2),
            context: context) +
        widget.handleSectionHeight;
  }

  void _disableAutoResizeAnimation() {
    animation = false;
    _runAfterBuild(() => animation = true);
  }

  void _changeWithNotifyStateAndHeight() {
    if (lastMoveState != moveState) {
      lastMoveState = moveState;
      _notifyMoveStateChanged();
    }

    if (lastHeight != nowHeight) {
      lastHeight = nowHeight;
      _notifyHeightChanged();
    }
  }

  void _notifyMoveStateChanged() {
    if (widget.onStateChanged != null) {
      _runAfterBuild(() => widget.onStateChanged?.call(moveState));
    }
  }

  void _notifyHeightChanged() {
    if (widget.onHeightChanged != null) {
      _runAfterBuild(() => widget.onHeightChanged?.call(nowHeight));
    }
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
    return Positioned.fill(top: null, child: gestureDetector);
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
      onEnd: _onAnimationEnd,
      child: Container(
          decoration: decoration,
          child: Column(children: [_makeHandleSection(), _makeBodySection()])),
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
      flex: moveState.canExpanded ? 1 : (widget.height != null ? 1 : 0),
      child: Material(
          color: Colors.transparent,
          child: widget.builder(moveState, _move, _setState)));

  /* ----- Events ----- */

  DrawerState prevMoveState = DrawerState.noHeight;

  void _onDragStart(DragStartDetails details) {
    prevMoveState = moveState;
    moveState = moveState.nextRunningState;
    animation = false;
    rebuild();
  }

  late _Direction direction;

  bool animationExecuted = false;

  void _onDrag(DragUpdateDetails details) {
    direction = _checkDragDirection(details.delta.dy);

    if (!direction.isNone) {
      moveState = direction.isUp ? DrawerState.opening : DrawerState.closing;
    }

    final requestHeight = nowHeight - details.delta.dy;

    if (requestHeight != nowHeight &&
        (minHeight <= requestHeight &&
            requestHeight <= widget.expandedHeight)) {
      animationExecuted = true;
      nowHeight = requestHeight;
      rebuild();
    }
  }

  bool? willOpen;

  void _onDragEnd(DragEndDetails details) {
    if (direction.isNone) {
      willOpen = moveState == DrawerState.closing;
    } else {
      willOpen = direction.isUp;
    }

    nowHeight = getExpectHeight(willOpen!);
    animation = true;

    if (!animationExecuted) _prepareNotifyEnd();

    rebuild();
  }

  void _onAnimationEnd() {
    if (moveWithControlMethod) {
      moveState = moveState.nextFinishState;
      moveWithControlMethod = false;
      rebuild();
    } else if (willOpen != null) {
      animationExecuted = false;
      _prepareNotifyEnd();
      _runAfterBuild(() => rebuild());
    }
  }

  double getExpectHeight(bool open) => open ? widget.expandedHeight : minHeight;

  void _prepareNotifyEnd() {
    moveState = DrawerState.getFinishState(willOpen!);
    willOpen = null;
  }

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
    moveState = DrawerState.noHeight;
    func.call();
    rebuild();
  }

  /* ----- utils ----- */

  static _Direction _checkDragDirection(double deltaY) {
    if (deltaY == 0) return _Direction.none;
    return deltaY < 0 ? _Direction.up : _Direction.down;
  }

  static void _runAfterBuild(Function() callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  void rebuild() => setState(() {});
}

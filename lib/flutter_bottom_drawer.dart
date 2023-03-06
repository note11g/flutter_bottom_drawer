library flutter_bottom_drawer;

import 'package:flutter/material.dart';

class BottomDrawer extends StatefulWidget {
  final double? height;
  final double expandedHeight;
  final Color backgroundColor;
  final Color handleColor;
  final List<BoxShadow>? shadows;
  final double handleSectionHeight;
  final Size handleSize;
  final double radius;
  final bool resizingAnimation;
  final Duration resizeAnimationDuration;

  final Widget Function(
      double nowBodyHeight,
      BottomDrawerState state,
      void Function(bool open) open,
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
    this.resizingAnimation = true,
    this.resizeAnimationDuration = const Duration(milliseconds: 300),
    required this.builder,
  }) : super(key: key);

  @override
  State<BottomDrawer> createState() => _BottomDrawerState();

  static const defaultShadow =
      BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black26);
}

class _BottomDrawerState extends State<BottomDrawer> {
  final handleKey = GlobalKey();
  final containerKey = GlobalKey();

  double nowHeight = 0;
  bool animation = true, opened = false;

  /// minHeight 가 null 인 경우 : 위젯의 높이를 자동으로 측정하여 설정
  double? minHeight;

  double? autoDetectedHeight;

  BottomDrawerState moveState = BottomDrawerState.noHeight;

  @override
  Widget build(BuildContext context) {
    minHeight = widget.height ?? autoDetectedHeight;

    if (nowHeight == 0 && minHeight != null) {
      nowHeight = minHeight!;
      moveState = BottomDrawerState.closed;
    } else if (moveState == BottomDrawerState.noHeight && minHeight != null) {
      if (!widget.resizingAnimation) animation = false;
      nowHeight = minHeight!;
      _runAfterBuild(() => animation = true);
    }

    if (moveState == BottomDrawerState.closed ||
        moveState == BottomDrawerState.noHeight) {
      _runAfterBuild(() {
        final expandedHeight = _measureWidgetSize(containerKey).height;
        final h = widget.handleSectionHeight + expandedHeight;

        if (autoDetectedHeight != h) {
          setState(() {
            autoDetectedHeight = h;
            _runAfterBuild(() {
              setState(() => moveState = BottomDrawerState.closed);
            });
          });
        } else {
          moveState = BottomDrawerState.closed;
        }
      });
    }

    return _makePositionedGestureDetector();
  }

  /* ----- widget maker ----- */

  Widget _makePositionedGestureDetector() {
    final gestureDetector = GestureDetector(
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
      child: Column(children: [_makeHandleSection(), _makeBodySection()]),
    );
  }

  Widget _makeHandleSection() => Container(
      key: handleKey,
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
      key: containerKey,
      flex: moveState.canExpanded ? 1 : 0,
      child: widget.builder(
          nowHeight - widget.handleSectionHeight, moveState, _open, _setState));

  /* ----- Drag Events ----- */

  void _onDragStart(DragStartDetails details) {
    animation = false;
    moveState = BottomDrawerState.moving;
  }

  void _onDrag(DragUpdateDetails details) {
    final requestHeight = nowHeight - details.delta.dy;

    if (minHeight! <= requestHeight && requestHeight <= widget.expandedHeight) {
      setState(() => nowHeight = requestHeight);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    animation = true;
    final dragDirection = _checkDragDirection(details);

    switch (dragDirection) {
      case _Direction.up:
        opened = true;
        nowHeight = widget.expandedHeight;
        break;
      case _Direction.down:
        opened = false;
        nowHeight = minHeight!;
        break;
    }

    setState(() {});

    Future.delayed(widget.resizeAnimationDuration, () {
      setState(() {
        // todo : remove timeBased event sending
        moveState =
            opened ? BottomDrawerState.opened : BottomDrawerState.closed;
      });
    });
  }

  /* ----- control methods ----- */

  void _setState(void Function() func) {
    setState(() {
      if (widget.height == null) moveState = BottomDrawerState.noHeight;
      func.call();
    });
  }

  void _open(bool open) {
    final height = open ? widget.expandedHeight : minHeight!;
    moveState = BottomDrawerState.moving;
    setState(() => nowHeight = height);
    Future.delayed(
        widget.resizeAnimationDuration,
        () => setState(() {
              moveState =
                  open ? BottomDrawerState.opened : BottomDrawerState.closed;
              if (widget.height == null && !open) {
                moveState = BottomDrawerState.noHeight;
              }
            }));
  }

  /* ----- utils ----- */

  static _Direction _checkDragDirection(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    return velocity.dy < 0 ? _Direction.up : _Direction.down;
  }

  static Size _measureWidgetSize(GlobalKey key) {
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size;
  }

  static void _runAfterBuild(Function() callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }
}

enum BottomDrawerState {
  noHeight,
  opened,
  closed,
  moving;

  bool get canExpanded =>
      this != BottomDrawerState.noHeight && this != BottomDrawerState.closed;
}

enum _Direction { up, down }

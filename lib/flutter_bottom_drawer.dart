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
  late double nowHeight;
  double minHeight = 0, lastHeight = 0;
  bool animation = true;

  DrawerState moveState = DrawerState.noHeight;
  DrawerState lastMoveState = DrawerState.noHeight;

  late final _MoveController moveController;

  _BottomDrawerState() {
    moveController = _MoveController(
      rebuild: _rebuild,
      runAfterBuild: _runAfterBuild,
      getNowHeight: () => nowHeight,
      setNowHeight: (height) => nowHeight = height,
      getMoveState: () => moveState,
      setMoveState: (state) => moveState = state,
      getMinHeight: () => minHeight,
      getExpandedHeight: () => widget.expandedHeight,
      setAnimation: (value) => animation = value,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (moveState._needHeightUpdate) {
      _setHeight();
      if (!widget.autoResizingAnimation) _disableAutoResizeAnimation();
    }

    _changeWithNotifyStateAndHeight();

    return _makeDrawer();
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

  Widget _makeDrawer() {
    final gestureDetector = GestureDetector(
      onTap: () {
        /* ignore event */
      },
      onVerticalDragStart: moveController.onDragStart,
      onVerticalDragEnd: moveController.onDragEnd,
      onVerticalDragUpdate: moveController.onDrag,
      child: _makeAnimatedContainer(),
    );
    return Positioned.fill(top: null, child: gestureDetector);
  }

  Widget _makeAnimatedContainer() {
    final radius = Radius.circular(widget.cornerRadius);
    final innerContainer = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
          color: widget.backgroundColor,
          boxShadow: widget.shadows,
        ),
        child: Column(children: [_makeHandleSection(), _makeBodySection()]));

    print(nowHeight);

    return AnimatedContainer(
      onEnd: moveController.onAnimationEnd,
      height: nowHeight != 0 ? nowHeight : null,
      //  todo : need test (0인 경우를 Trace 해봐야 함)
      duration: animation ? widget.resizeAnimationDuration : Duration.zero,
      curve: Curves.ease,
      child: innerContainer,
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
          child: widget.builder(moveState, moveController.move, _setState)));

  void _setState(void Function() func) {
    moveState = DrawerState.noHeight;
    setState(func);
  }

  /* ----- utils ----- */

  static void _runAfterBuild(Function() callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  void _rebuild() => setState(() {});
}

class _MoveController {
  final void Function() rebuild;
  final void Function(Function() callback) runAfterBuild;
  final double Function() getNowHeight;
  final void Function(double height) setNowHeight;
  final DrawerState Function() getMoveState;
  final void Function(DrawerState state) setMoveState;
  final double Function() getMinHeight;
  final double Function() getExpandedHeight;
  final void Function(bool value) setAnimation;

  double get nowHeight => getNowHeight();

  set nowHeight(double height) => setNowHeight(height);

  DrawerState get moveState => getMoveState();

  set moveState(DrawerState state) => setMoveState(state);

  double get minHeight => getMinHeight();

  double get expandedHeight => getExpandedHeight();

  set animation(bool value) => setAnimation(value);

  _MoveController({
    required this.rebuild,
    required this.runAfterBuild,
    required this.getNowHeight,
    required this.setNowHeight,
    required this.getMoveState,
    required this.setMoveState,
    required this.getMinHeight,
    required this.getExpandedHeight,
    required this.setAnimation,
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
    animation = false;
    rebuild();
  }

  void onDrag(DragUpdateDetails details) {
    final deltaY = details.delta.dy;
    final requestHeight = nowHeight - deltaY;

    direction = _Direction.fromDragDelta(deltaY);

    if (requestHeight != nowHeight && _isValidHeight(requestHeight)) {
      animationExecuted = true;
      nowHeight = requestHeight;

      if (!direction.isNone) {
        moveState = DrawerState.getRunningState(isOpening: direction.isUp);
      }

      rebuild();
    }
  }

  bool _isValidHeight(double height) =>
      minHeight <= height && height <= expandedHeight;

  void onDragEnd(DragEndDetails details) {
    if (direction.isNone) {
      willOpen = moveState == DrawerState.closing;
    } else {
      willOpen = direction.isUp;
    }

    nowHeight = getExpectHeight(willOpen!);
    animation = true;

    if (!animationExecuted) _prepareNotifyFinishState();

    rebuild();
  }

  void onAnimationEnd() {
    if (controlWithMoveMethod) {
      moveState = moveState.nextFinishState;
      controlWithMoveMethod = false;
      rebuild();
    } else if (willOpen != null) {
      animationExecuted = false;
      _prepareNotifyFinishState();
      runAfterBuild(() => rebuild());
    }
  }

  double getExpectHeight(bool open) => open ? expandedHeight : minHeight;

  void _prepareNotifyFinishState() {
    moveState = DrawerState.getFinishState(isOpened: willOpen!);
    willOpen = null;
  }

  void move(bool open) {
    animation = true;
    nowHeight = getExpectHeight(open);
    moveState = DrawerState.getRunningState(isOpening: open);
    controlWithMoveMethod = true;
    rebuild();
  }
}

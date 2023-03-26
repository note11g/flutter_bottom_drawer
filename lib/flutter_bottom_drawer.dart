library flutter_bottom_drawer;

import 'package:flutter/material.dart';

import 'src/enum/drawer_state.dart';
import 'src/measure_util.dart';
import 'src/state/state_controller.dart';
import 'src/state/state_controller_impl.dart';
import 'src/move/move_controller.dart';
import 'src/move/move_handler.dart';

export 'src/enum/drawer_state.dart';
export 'src/move/move_controller.dart';

/// widget that can be dragged up and down like a drawer
class BottomDrawer extends StatefulWidget {
  /// closed height of the drawer.
  /// if null, the height is set to the height of the child widget.
  final double? height;

  /// expanded height of the drawer.
  final double expandedHeight;

  /// background color of the drawer.
  /// default is white.
  final Color backgroundColor;

  /// color of the handle.
  /// default is #E0E0E0
  final Color handleColor;

  /// shadows of the drawer.
  /// default is [defaultShadow].
  final List<BoxShadow>? shadows;

  /// height of the handle section.
  /// default is 28.
  final double handleSectionHeight;

  /// size of the handle.
  /// default is 40x4.
  final Size handleSize;

  /// corner radius of the drawer.
  /// default is 8.
  final double cornerRadius;

  /// if true, the drawer will be auto resized with animation when the height is changed. (when height is null only)
  /// it's cause overflow. so if you want to use this, [autoResizingAnimation]=[kReleaseMode] is recommended.
  /// default is false.
  final bool autoResizingAnimation;

  /// duration of the auto resizing animation.
  /// default is 300ms.
  final Duration resizeAnimationDuration;

  /// callback when the height is changed.
  final void Function(double height)? onHeightChanged;

  /// callback when the state is changed.
  final void Function(DrawerState state)? onStateChanged;

  /// callback when the drawer is ready.
  /// you can use [DrawerMoveController] to control the drawer.
  final void Function(DrawerMoveController controller)? onReady;

  /// builder of the drawer.
  /// [DrawerState] is the current state of the drawer.
  /// [setState] is the setState function of the drawer. it can be used to rebuild the drawer. (and, when [height]=null, height will be remeasured)
  /// [context] is the context of the drawer.
  final Widget Function(DrawerState state,
      void Function(void Function()) setState, BuildContext context) builder;

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
    this.onReady,
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
  late final StateController controller = StateControllerImpl(
    getHeight: () => widget.height,
    getExpandedHeight: () => widget.expandedHeight,
    measureDrawerHeight: _measureDrawerHeight,
  );
  late final MoveHandler moveController =
      MoveHandler(rebuild: _rebuild, stateController: controller);

  double _measureDrawerHeight() {
    final bodyHeight =
        measureWidgetHeight(_makeBody(isMock: true), context: context);
    return bodyHeight + widget.handleSectionHeight;
  }

  @override
  void initState() {
    widget.onReady?.call(moveController);
    super.initState();
  }

  /* ----- Build ----- */

  @override
  Widget build(BuildContext context) {
    if (controller.needHeightInitialize) {
      controller.initializeHeight();
      if (!widget.autoResizingAnimation) tempDisableAutoResizeAnimation();
    }

    changeStateAndHeightWithNotify();

    return _makeDrawer();
  }

  void tempDisableAutoResizeAnimation() {
    controller.disableAnimation();
    _runAfterBuild(() => controller.enableAnimation());
  }

  double? lastHeight;
  DrawerState? lastDrawerState;

  void changeStateAndHeightWithNotify() {
    final drawerState = controller.drawerState;
    if (lastDrawerState != drawerState) {
      lastDrawerState = drawerState;
      _notifyWithCallback(drawerState, callback: widget.onStateChanged);
    }

    final nowHeight = controller.nowHeight;
    if (lastHeight != nowHeight) {
      lastHeight = nowHeight;
      _notifyWithCallback(nowHeight, callback: widget.onHeightChanged);
    }
  }

  /* ----- utils ----- */

  static void _notifyWithCallback<T>(T v, {required Function(T)? callback}) {
    if (callback != null) _runAfterBuild(() => callback.call(v));
  }

  static void _runAfterBuild(Function() callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  void _setState(void Function() func) {
    controller.notifyHeightInitializeNeed();
    setState(func);
  }

  void _rebuild() => setState(() {});

  /* ----- widget ----- */

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

  Widget _makeHandleSection() {
    final handle = Container(
      width: widget.handleSize.width,
      height: widget.handleSize.height,
      decoration: BoxDecoration(
          color: widget.handleColor, borderRadius: BorderRadius.circular(1000)),
    );
    return Container(
        width: double.infinity,
        height: widget.handleSectionHeight,
        alignment: Alignment.center,
        child: handle);
  }

  Widget _makeBodySection() {
    final needExpand =
        controller.drawerState.canExpanded ? true : isDefinedHeight;
    return Expanded(flex: needExpand ? 1 : 0, child: _makeBody());
  }

  Widget _makeBody({bool isMock = false}) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Material(
          type: MaterialType.transparency,
          child: widget.builder(
              isMock ? DrawerState.closed : controller.drawerState,
              isMock ? (void Function() f) {} : _setState,
              context)),
    );
  }

  bool get isDefinedHeight => widget.height != null;
}

import 'package:flutter_bottom_drawer/src/enum/direction.dart';
import 'package:flutter_bottom_drawer/src/enum/drawer_state.dart';

class StateController {
  final double? Function() _getHeight;
  final double Function() _getExpandedHeight;
  final double Function() _measureDrawerHeight;

  StateController({
    required double? Function() getHeight,
    required double Function() getExpandedHeight,
    required double Function() measureDrawerHeight,
  })  : _getHeight = getHeight,
        _getExpandedHeight = getExpandedHeight,
        _measureDrawerHeight = measureDrawerHeight;

  late double _nowHeight;
  late double _minHeight;

  double get nowHeight => _nowHeight;

  DrawerState _drawerState = DrawerState.needUpdate;

  DrawerState get drawerState => _drawerState;

  bool _animationEnable = true;

  bool get animationEnabled => _animationEnable;

  void prepareMove({required bool open}) {
    _movingState(opening: open);
    _changeHeight(_targetHeight(open));
    enableAnimation();
  }

  void updateHeight() {
    _setMinHeight(_getHeight() ?? _measureDrawerHeight());
    _changeHeight(_minHeight);
    _drawerState = DrawerState.closed;
  }

  void _setMinHeight(double height) => _minHeight = height;

  void _changeHeight(double height) => _nowHeight = height;

  void _movingState({required bool opening}) {
    _drawerState = DrawerState.getRunningState(isOpening: opening);
  }

  double _targetHeight(bool open) => open ? _getExpandedHeight() : _minHeight;

  bool isValidHeight(double height) =>
      _minHeight < height && height < _getExpandedHeight();

  void enableAnimation() => _animationEnable = true;

  void disableAnimation() => _animationEnable = false;

  void finishedState() {
    _drawerState = drawerState.nextFinishState;
  }

  void notifyUpdatedNeeded() {
    _drawerState = DrawerState.needUpdate;
  }

  void dragUpdateWhenNeedUpdate({
    required double height,
    required Direction direction,
    required Function() onUpdated,
  }) {
    if (_needDragUpdate(height, direction)) {
      _dragUpdate(height, direction);
      onUpdated.call();
    }
  }

  bool _needDragUpdate(double height, Direction direction) =>
      !direction.isNone && isValidHeight(height);

  void _dragUpdate(double height, Direction direction) {
    _changeHeight(height);
    _movingState(opening: direction.isUp);
  }
}

import 'enum/direction.dart';
import 'enum/drawer_state.dart';
import 'state_controller.dart';

class StateControllerImpl with StateController {
  final double? Function() _getHeight;
  final double Function() _getExpandedHeight;
  final double Function() _measureDrawerHeight;

  StateControllerImpl({
    required double? Function() getHeight,
    required double Function() getExpandedHeight,
    required double Function() measureDrawerHeight,
  })  : _getHeight = getHeight,
        _getExpandedHeight = getExpandedHeight,
        _measureDrawerHeight = measureDrawerHeight;

  late double _nowHeight;
  late double _minHeight;
  DrawerState _drawerState = DrawerState.needUpdate;
  bool _animationEnable = true;

  @override
  double get nowHeight => _nowHeight;

  @override
  DrawerState get drawerState => _drawerState;

  @override
  bool get animationEnabled => _animationEnable;

  /* ----- animation ----- */

  @override
  void enableAnimation() => _animationEnable = true;

  @override
  void disableAnimation() => _animationEnable = false;

  /* ----- move ----- */

  @override
  void manualMove({required double height, required Direction direction}) {
    _updateHeight(height);
    _notifyNowMoving(opening: direction.isUp);
  }

  @override
  void prepareAutoMove() {
    disableAnimation();
  }

  @override
  void requestAutoMove({required bool open}) {
    _updateTargetHeight(open: open);
    _notifyNowMoving(opening: open);
    enableAnimation();
  }

  @override
  void finishMove() {
    _notifyMoveFinished();
  }

  @override
  bool get isRequestedMove => animationEnabled;

  /* ----- update height ----- */

  @override
  void initializeHeight() {
    _minHeight = _getHeight() ?? _measureDrawerHeight();
    _nowHeight = _minHeight;
    _drawerState = DrawerState.closed;
  }

  void _updateTargetHeight({required bool open}) {
    final targetHeight = open ? _getExpandedHeight() : _minHeight;
    _updateHeight(targetHeight);
  }

  void _updateHeight(double height) {
    _nowHeight = height;
  }

  /* ----- notify now state ----- */

  @override
  void notifyHeightInitializeNeed() {
    _drawerState = DrawerState.needUpdate;
  }

  void _notifyNowMoving({required bool opening}) {
    _drawerState = DrawerState.getRunningState(isOpening: opening);
  }

  void _notifyMoveFinished() {
    _drawerState = drawerState.nextFinishState;
  }

  // check can move

  @override
  bool canManualMove(double height, Direction direction) =>
      !direction.isNone && _isValidHeight(height);

  bool _isValidHeight(double height) =>
      _minHeight < height && height < _getExpandedHeight();
}

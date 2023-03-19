import '../enum/direction.dart';
import '../enum/drawer_state.dart';
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
  double _minHeight = -1;
  DrawerState _drawerState = DrawerState.closed;
  bool _needHeightInitialize = true;
  bool _animationEnable = true;

  @override
  double get nowHeight => _nowHeight;

  double get minHeight => _minHeight;

  double get expandedHeight => _getExpandedHeight();

  @override
  bool get needHeightInitialize => _needHeightInitialize;

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
    assert(needHeightInitialize);
    _updateMinHeight();
    if (drawerState == DrawerState.closed) _updateHeight(minHeight);
    _notifyHeightInitialized();
  }

  void _updateTargetHeight({required bool open}) {
    final targetHeight = open ? expandedHeight : minHeight;
    _updateHeight(targetHeight);
  }

  void _updateHeight(double height) {
    _nowHeight = height;
  }

  void _updateMinHeight() {
    _minHeight = _getHeight() ?? _measureDrawerHeight();
  }

  /* ----- notify ----- */

  @override
  void notifyHeightInitializeNeed() {
    _needHeightInitialize = true;
  }

  void _notifyHeightInitialized() {
    _needHeightInitialize = false;
  }

  void _notifyNowMoving({required bool opening}) {
    _drawerState = DrawerState.getRunningState(isOpening: opening);
  }

  void _notifyMoveFinished() {
    _drawerState = drawerState.nextFinishState;
  }

  /* ----- check can move ----- */

  @override
  bool canManualMove(double height, Direction direction) =>
      !direction.isNone && _isValidHeight(height);

  bool _isValidHeight(double height) =>
      minHeight < height && height < expandedHeight;
}

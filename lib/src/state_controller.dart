import 'enum/direction.dart';
import 'enum/drawer_state.dart';

mixin StateController {
  bool get needHeightInitialize;

  double get nowHeight;

  DrawerState get drawerState;

  // initialize height

  void initializeHeight();

  void notifyHeightInitializeNeed();

  // animation

  bool get animationEnabled;

  void enableAnimation();

  void disableAnimation();

  // move (with notify)

  void manualMove({required double height, required Direction direction});

  bool canManualMove(double height, Direction direction);

  void prepareAutoMove();

  void requestAutoMove({required bool open});

  bool get isRequestedMove;

  void finishMove();
}

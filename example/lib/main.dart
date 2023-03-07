import 'package:flutter/material.dart';
import 'package:flutter_bottom_drawer/flutter_bottom_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ExamplePage());
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  late Function(bool) moveFunc;
  double drawerHeight = 0;
  DrawerState? drawerState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: drawerHeight,
              child: Scaffold(
                backgroundColor: Colors.grey,
                floatingActionButton: FloatingActionButton(
                  onPressed: bottomDrawerMove,
                  child: drawerState != DrawerState.opened
                      ? const Icon(Icons.arrow_upward)
                      : const Icon(Icons.arrow_downward),
                ),
              )),
          _bottomDrawer(),
        ],
      ),
    );
  }

  void bottomDrawerMove() {
    moveFunc.call(drawerState != DrawerState.opened);
    setState(() {});
  }

  bool expanded = false;

  Widget _bottomDrawer() {
    return BottomDrawer(
        expandedHeight: 500,
        builder: (height, state, move, setStateOnDrawer) {
          print("state: $state, height: $height");

          moveFunc = move;

          if (drawerState != state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => drawerState = state);
            });
          }

          if (drawerHeight != height) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => drawerHeight = height);
            });
          }

          return Container(
            color: Colors.red,
            height: expanded ? 200 : 100,
            child: Center(
              child: ElevatedButton(
                  onPressed: () => setStateOnDrawer(() => expanded = !expanded),
                  child: Text(expanded ? 'flip' : 'expand')),
            ),
          );
        });
  }
}

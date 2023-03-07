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
  String nowState = 'open';

  Function(bool)? moveFunc;
  double drawerHeight = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight - drawerHeight,
              color: Colors.blue,
              child: Center(
                  child: ElevatedButton(
                      onPressed: () {
                        if (nowState == 'close') {
                          setState(() => nowState = 'open');
                          moveFunc?.call(false);
                        } else if (nowState == 'open') {
                          setState(() => nowState = 'close');
                          moveFunc?.call(true);
                        }
                      },
                      child: Text(nowState))),
            ),
          ),
          _bottomDrawer(),
        ],
      ),
    );
  }

  bool expanded = false;

  Widget _bottomDrawer() {
    return BottomDrawer(
        expandedHeight: 500,
        builder: (height, state, move, setStateOnDrawer) {
          moveFunc = move;
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

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
    return Stack(children: [
      Positioned.fill(child: _mainSection()),
      _bottomDrawer(),
    ]);
  }

  Widget _mainSection() => Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(children: [
        Positioned.fill(bottom: drawerHeight, child: _contents()),
        _fab(bottomMargin: 16 + drawerHeight),
      ]));

  Widget _contents() => ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) => ListTile(
          title: Text('item $index'),
        ),
      );

  Widget _fab({double rightMargin = 16, double bottomMargin = 16}) =>
      Positioned(
          right: rightMargin,
          bottom: bottomMargin,
          child: FloatingActionButton(
            onPressed: bottomDrawerMove,
            child: drawerState != DrawerState.opened
                ? const Icon(Icons.arrow_upward)
                : const Icon(Icons.arrow_downward),
          ));

  void bottomDrawerMove() {
    moveFunc.call(drawerState != DrawerState.opened);
    setState(() {});
  }

  bool expanded = false;

  Widget _bottomDrawer() => BottomDrawer(
      expandedHeight: 500,
      builder: (height, state, move, setStateOnDrawer) {
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

import 'package:flutter/material.dart';
import 'package:flutter_bottom_drawer/flutter_bottom_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: ExamplePage());
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
  bool isDark = false;

  Color get backgroundColor =>
      isDark ? Colors.grey.shade900 : Colors.grey.shade50;

  Color get textColor => isDark ? Colors.white : Colors.black;

  Color get drawerHandleColor =>
      isDark ? Colors.grey.shade700 : Colors.grey.shade300;

  Color get drawerBackgroundColor =>
      isDark ? Colors.grey.shade800 : Colors.white;

  Color get drawerShadowColor => isDark ? Colors.white24 : Colors.black26;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: _mainSection()),
      _bottomDrawer(),
    ]);
  }

  Widget _mainSection() => Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(children: [
        Positioned.fill(bottom: drawerHeight, child: _contents()),
        _fab(bottomMargin: 16 + drawerHeight),
      ]));

  Widget _contents() => ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) => ListTile(
          title: Text('item $index', style: TextStyle(color: textColor))));

  Widget _fab({double rightMargin = 16, double bottomMargin = 16}) =>
      Positioned(
          right: rightMargin,
          bottom: bottomMargin,
          child: FloatingActionButton(
            onPressed: bottomDrawerMove,
            child: drawerState == DrawerState.opened ||
                    drawerState == DrawerState.closing
                ? const Icon(Icons.arrow_downward)
                : const Icon(Icons.arrow_upward),
          ));

  void bottomDrawerMove() {
    moveFunc.call(drawerState != DrawerState.opened);
    setState(() {});
  }

  bool expanded = false;

  Widget _bottomDrawer() => BottomDrawer(
      expandedHeight: 500,
      handleColor: drawerHandleColor,
      backgroundColor: drawerBackgroundColor,
      shadows: [
        BoxShadow(
          offset: const Offset(0, 2),
          blurRadius: 4,
          color: drawerShadowColor,
        )
      ],
      onStateChanged: (state) {
        setState(() => drawerState = state);
      },
      onHeightChanged: (height) {
        setState(() => drawerHeight = height);
      },
      builder: (state, move, setStateOnDrawer) {
        moveFunc = move;

        return SizedBox(
            height: expanded ? 300 : 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("state: $state", style: TextStyle(color: textColor)),
                  const SizedBox(height: 8),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    ElevatedButton(
                        onPressed: () {
                          setStateOnDrawer(() => expanded = !expanded);
                        },
                        child: Text(expanded ? 'flip' : 'expand')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                        onPressed: () => setState(() => isDark = !isDark),
                        child: Text(isDark ? 'lightmode' : 'darkmode')),
                  ]),
                ],
              ),
            ));
      });
}

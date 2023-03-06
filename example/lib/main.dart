import 'package:flutter/material.dart';
import 'package:flutter_bottom_drawer/flutter_bottom_drawer.dart';

void main() {
  runApp(const ExamplePage());
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  String nowState = 'open';

  Function(bool)? openFunc;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Center(
                child: ElevatedButton(
                    onPressed: () {
                      if (nowState == 'close') {
                        setState(() {
                          nowState = 'open';
                        });
                        openFunc?.call(false);
                      } else if (nowState == 'open') {
                        setState(() {
                          nowState = 'close';
                        });
                        openFunc?.call(true);
                      }
                    },
                    child: Text(nowState))),
            _bottomDrawer(),
          ],
        ),
      ),
    );
  }

  Widget _bottomDrawer() {
    return BottomDrawer(
        expandedHeight: 200,
        height: 100,
        resizingAnimation: false, // todo : fix
        resizeAnimationDuration: const Duration(milliseconds: 300),
        builder: (nowHeight, state, open, setState) {
          openFunc = open;
          print("state: $state, nowHeight: $nowHeight");
          return FlutterLogo(size: nowHeight);
        });
  }
}

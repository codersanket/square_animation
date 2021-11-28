import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: DragAnimation(),
    );
  }
}

class DragAnimation extends StatefulWidget {
  const DragAnimation({Key? key}) : super(key: key);

  @override
  State<DragAnimation> createState() => _DragAnimationState();
}

class _DragAnimationState extends State<DragAnimation>
    with TickerProviderStateMixin {
  late List<Square> list = [];

  void setAnimationController() {
    List.generate(
      8,
      (index) {
        animationController.add(AnimationController(
            vsync: this, duration: const Duration(milliseconds: 1000)));

        final color = Colors.accents[index];
        final delay = 10.0 * index;
        final size = 15.0 * index;

        animation.add(
            Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
                .animate(animationController[index]));

        list.add(Square(color, size, delay));
      },
    );
  }

  var _currentLocation = const Offset(0, 0);

  late List<AnimationController> animationController = [];
  late List<Animation> animation = [];

  @override
  void initState() {
    setAnimationController();
    super.initState();
  }

  setNewLocation(Offset newlocation) async {
    for (var i = 0; i < animation.length; i++) {
      animation[i] = Tween<Offset>(begin: _currentLocation, end: newlocation)
          .animate(CurvedAnimation(
              parent: animationController[i], curve: Curves.easeInOut));
    }

    for (var i = 0; i < animationController.length; i++) {
      if (i == 0) {
        animationController[i].forward(from: 0.0);
      } else {
        await Future.delayed(Duration(milliseconds: list[i].delay.toInt() * 2));
        animationController[i].forward(from: 0.0);
      }
    }
    _currentLocation = newlocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                setNewLocation(d.localPosition);
              },
              child: Stack(
                children: list
                    .asMap()
                    .entries
                    .map((e) => AnimatedBuilder(
                        animation: animationController[e.key],
                        builder: (contex, snapshot) {
                          return CustomPaint(
                            painter: Sqaures(
                              e.value,
                              animation[e.key].value,
                            ),
                          );
                        }))
                    .toList(),
              ),
            ),
          ),
        ));
  }
}

class Sqaures extends CustomPainter {
  final Square squre;
  final Offset pointerLocation;
  Sqaures(this.squre, this.pointerLocation);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(pointerLocation.dx, pointerLocation.dy),
            width: squre.squraeSize,
            height: squre.squraeSize),
        Paint()
          ..color = squre.squareColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Square {
  final Color squareColor;
  final double squraeSize;
  final double delay;

  Square(this.squareColor, this.squraeSize, this.delay);
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'const.dart' as Constants;

void main() {
  runApp(Phoenix(child:MaterialApp(
    home: MyApp(),
    title: "BMI Calculator",
    debugShowCheckedModeBanner: false,
  )));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final double maxSlide = 300.0;
  late Object person;
  late Scene _scene;
  late Object title;
  late double from;
  bool done = false;
  late double to;
  late TextField weight;
  late TextField height;
  late FloatingActionButton _floating;
  final List<TextEditingController> textControllers = <TextEditingController>[];

  int phase = 0;
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 2; i++) {
      textControllers.add(TextEditingController());
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )
      // ..addStatusListener((status) {
      //   if (status == AnimationStatus.forward ||
      //       status == AnimationStatus.reverse) {
      //     _animationController;
      //   }
      // })
      ..addListener(() {
        if (phase == 0 || phase == 1) {
          _scene.camera.target.y = 1 - (5 * _animationController.value);
          _scene.camera.zoom = 0.96 + (0.5 * _animationController.value);
          //(0,0)->(0,30), reverse: (0,0)->(0,-29)
          _scene.camera.trackBall(Vector2(0, from * _animationController.value),
              Vector2(0, to * _animationController.value));
        }
        if (phase == 2 &&
            textControllers[0].text.isNotEmpty &&
            textControllers[1].text.isNotEmpty) {
          // _scene.camera.target.y = -4+5*_animationController.value;
          // _scene.camera.zoom = 1.46-0.5*_animationController.value;
          // _scene.camera.trackBall(Vector2(0, from * _animationController.value),
          // Vector2(0, to-to * _animationController.value));
          person.rotation.y = (180 * _animationController.value / 2);
          person.position.x = 4.1 * _animationController.value;
          person.position.z = 0 * (_animationController.value);
          person.scale.y = 10 + (1.5 * _animationController.value);

          title.rotation.y = (180 * _animationController.value / 2);
          title.position.x = (3.5 * _animationController.value) - 0.5;
          title.position.z = 0 * (_animationController.value) - 1;
          title.position.y = 1.2 * (_animationController.value) + 4.5;
          person.updateTransform();
          title.updateTransform();
          _scene.update();
        }
      });
    person = (Object(
        fileName: 'assets/cns2/cns.obj',
        scale: Vector3(10.0, 10.0, 10.0),
        position: Vector3(0, 0, 0)));
    title = (Object(
      fileName: 'assets/title/bmitext1.obj',
      scale: Vector3(5, 5, 5),
      position: Vector3(-0.5, 4.5, -1),
    ));
    weight = TextField(
        controller: textControllers[0],
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter your weight in LBs',
        ),
        maxLines: 1,
        autofocus: false,
        keyboardType: TextInputType.number);
    height = TextField(
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter your height in inches'),
      maxLines: 1,
      autofocus: false,
      keyboardType: TextInputType.number,
      controller: textControllers[1],
    );
    _floating = FloatingActionButton(
        onPressed: tap,
        backgroundColor: Colors.grey,
        child: (phase >= 1) ? Icon(Icons.restart_alt) : Icon(Icons.navigation));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    for (TextEditingController i in textControllers) {
      i.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> tap() async {
    // if (_animationController.isDismissed) {
    //   from = 0;
    //   to = 30;
    //   _animationController.forward();
    // } else {
    //    from = 0;
    //       to = -29;
    //   _animationController.reverse();
    // }
    if (phase == 0) {
      from = 0;
      to = 30;

      _animationController.forward();
      phase++;
    } else if (phase == 1 &&
        textControllers[0].text.isNotEmpty &&
        textControllers[1].text.isNotEmpty) {
      from = 0;
      to = -29;
      await _animationController.reverse();
      phase++;
      Future.delayed(const Duration(milliseconds: 400),
          (() => _animationController.forward()));

      // } else {
      //   _animationController.isDismissed
      //       ? _animationController.forward()
      //       : _animationController.reverse();
      // }
    }
    // else{
    //   Phoenix.rebirth(context);
    // }
  }

  @override
  Widget build(BuildContext context) {
    var myChild = Cube(
      onSceneCreated: (Scene scene) {
        _scene = scene;
        _scene.camera.position.z = 25;
        _scene.camera.target.y = 1.0;
        _scene.camera.zoom = 0.96;
        _scene.camera.fov = 30;
        _scene.world.add(person);
        _scene.world.add(title);
        person.rotation.x = 0;
        person.updateTransform();
        _scene.update();
      },
    );

//shading as pages turn
    Animatable<Color?> background = TweenSequence<Color?>([
      TweenSequenceItem(
          tween: ColorTween(
              begin: Constants.frontPage, end: Constants.frontPageShade),
          weight: 1)
    ]);
    Animatable<Color?> background2 = TweenSequence<Color?>([
      TweenSequenceItem(
          tween:
              ColorTween(end: Constants.drawer, begin: Constants.drawerShade),
          weight: 1)
    ]);
    Widget result() {
      return Stack(
        clipBehavior: Clip.antiAlias,
        children: <Widget>[
          Transform.translate(
            //1.82
            offset: Offset(maxSlide * (_animationController.value - 1.22), 0),
            child: Transform(
                child: Container(
                  color: background2.evaluate(
                      AlwaysStoppedAnimation(_animationController.value)),
                  child: Center(
                      child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          const BoxShadow(
                              offset: Offset(10, 12),
                              color: Colors.black38,
                              blurRadius: 20),
                          BoxShadow(
                              offset: Offset(-10, -10),
                              color: Constants.drawer.withOpacity(0.85),
                              blurRadius: 10)
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                          '     Your \n   BMI \n is: \n' +
                              (double.parse(textControllers[0].text) /
                                      2.205 /
                                      (math.pow(
                                          (double.parse(
                                                  textControllers[1].text) /
                                              39.37),
                                          2)))
                                  .toStringAsFixed(2),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 55,
                              shadows: [
                                const Shadow(
                                    blurRadius: 10,
                                    offset: Offset(5, 5),
                                    color: Colors.black38),
                                Shadow(
                                    blurRadius: 10,
                                    offset: Offset(-2, -2),
                                    color: Colors.white.withOpacity(0.85))
                              ])),
                    ),
                  )),
                ),
                alignment: Alignment.centerRight,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY((math.pi / 2 * 0.1) * (_animationController.value))
                  ..setEntry(1, 1, 1.1)),
          ),
          Transform.translate(
            offset: Offset(300 * (_animationController.value), 0),
            child: Transform(
                child: Container(
                  color: background.evaluate(
                      AlwaysStoppedAnimation(_animationController.value)),
                  height: MediaQuery.of(context).size.height * 1.2,
                ),
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(-(math.pi / 2 + 0.05) * _animationController.value)
                  ..setEntry(1, 1, 1.4)),
          ),
          myChild,
        ],
      );
    }

    Widget scaleView() {
      return Stack(
        clipBehavior: Clip.antiAlias,
        children: <Widget>[
          Transform(
              child: Container(
                color: Constants.frontPage,
                height: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX((math.pi / 4) * _animationController.value)
                ..setEntry(0, 0, 1.4)),
          Transform.translate(
            offset: Offset(
                0,
                MediaQuery.of(context).size.height /
                    (0.8 + 1.35 * _animationController.value)),
            child: Transform(
              child: Container(color: Constants.infoPage),
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..scale(1.5 / (1 + 0.5 * _animationController.value)),
            ),
          ),
          myChild,
          Transform.translate(
            offset: Offset(
                0,
                MediaQuery.of(context).size.height /
                    (0.8 + 0.5 * _animationController.value)),
            child: Transform(
              child: Container(
                color: Constants.infoPage,
                alignment: Alignment.topCenter,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: weight,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: height,
                  ),
                ]),
              ),
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..scale(1.5 / (1 + 0.5 * _animationController.value)),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return Container(
              color: Constants.background,
              child: (phase == 2) ? result() : scaleView());
        },
      ),
      floatingActionButton: _floating,
      resizeToAvoidBottomInset: true,
    );
  }
}

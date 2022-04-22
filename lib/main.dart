import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_cube/flutter_cube.dart';
import 'const.dart' as Constants;

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    title: "BMI Calculator",
  ));
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
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    )..addListener(() {
        person.rotation.y = (180 * _animationController.value / 2);
        person.position.x = 4.5 * _animationController.value;
        person.position.z = 0 * (_animationController.value);
        person.scale.y = 10 + (1.5 * _animationController.value);
        //person.position.y = 0.3 * (_animationController.value);

        title.rotation.y = (180 * _animationController.value / 2);
        title.position.x = (3.5 * _animationController.value) - 0.5;
        title.position.z = 0 * (_animationController.value) - 1;
        title.position.y = 0.9 * (_animationController.value) + 4.5;
        person.updateTransform();
        title.updateTransform();

        _scene.update();
      });
    person = (Object(
        fileName: 'assets/Chimpanzee/chimp.obj',
        scale: Vector3(10.0, 10.0, 10.0)));
    title = (Object(
      fileName: 'assets/title/bmitext1.obj',
      scale: Vector3(5, 5, 5),
    ));
  }

  void toggle() {
    _animationController.isDismissed
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    var myDrawer = Container(
      height: MediaQuery.of(context).size.height,
      //1.26

      color: Constants.drawer,
    );
    var myChild = Cube(
      onSceneCreated: (Scene scene) {
        _scene = scene;
        _scene.camera.position.z = 25;
        _scene.camera.target.y = 1.0;
        _scene.camera.zoom = 0.96;
        _scene.camera.fov = 30;
        _scene.world.add(person);
        _scene.world.add(title);
        person.rotation.x = -1;
        person.updateTransform();
        title.position.setValues(-0.5, 4.5, -1);
        title.updateTransform();
        _scene.update();
        _scene.camera.target;
      },
    );
//shading as the front page turns
    Animatable<Color?> background = TweenSequence<Color?>([
      TweenSequenceItem(
          tween: ColorTween(
              begin: Constants.frontPage, end: Constants.frontPageShade),
          weight: 1)
    ]);

    return GestureDetector(
        onTap: toggle,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            return Container(
                //clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Constants.background,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Transform.translate(
                      //1.82
                      offset: Offset(
                          maxSlide * (_animationController.value - 1.22), 0),
                      child: Transform(
                          child: myDrawer,
                          alignment: Alignment.centerRight,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY((math.pi / 2 * 0.1) *
                                (_animationController.value))
                            ..setEntry(1, 1, 1.1)),
                    ),
                    Transform.translate(
                      offset: Offset(300 * (_animationController.value), 0),
                      child: Transform(
                          child: Container(
                            color: background.evaluate(AlwaysStoppedAnimation(
                                _animationController.value)),
                            height: MediaQuery.of(context).size.height * 1.2,
                          ),
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..scaled(1.5)
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(-(math.pi / 2 + 0.1) *
                                _animationController.value)
                            ..setEntry(1, 1, 1.5)),
                    ),
                    myChild,
                  ],
                ));
          },
        ));
  }
}

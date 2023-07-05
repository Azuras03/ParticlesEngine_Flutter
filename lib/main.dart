import 'dart:math';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:particlesengine/model/Particle.dart';
import 'package:particlesengine/vue/VueParticle.dart';

void main() {
  List<Particle> particles = [];
  runApp(ParticleEngine(particles));
}

class ParticleEngine extends StatefulWidget {
  final List<Particle> _particles;
  static const double gravity = 0.5;
  static const double friction = 0.99;
  static const double maxTime = 5;
  static const double size = 10;
  static const int nbParticlesClick = 20;
  static const int nbParticlesDrag = 2;

  const ParticleEngine(this._particles, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ParticleEngineState();
  }
}

class ParticleEngineState extends State<ParticleEngine>
    with SingleTickerProviderStateMixin {
  Icon icon = const Icon(Icons.pause);
  bool isPlaying = true;
  late VueParticle vueParticle;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 100000000));
    _controller.forward();
  }

  void replay() {
    print("replay");
    setState(() {
      widget._particles.clear();
    });
  }

  void changeIcon() {
    setState(() {
      if (isPlaying) {
        icon = const Icon(Icons.play_arrow);
        stopAnimation();
      } else {
        icon = const Icon(Icons.pause);
        startAnimation();
      }
      isPlaying = !isPlaying;
    });
  }

  void stopAnimation() {
    _controller.stop();
  }

  void startAnimation() {
    _controller.forward();
  }

  void addParticlesClick(PointerEvent details) {
    if (!isPlaying) return;
    Color color = Color.fromARGB(255, Random().nextInt(255),
        Random().nextInt(255), Random().nextInt(255));
    for (int i = 0; i < ParticleEngine.nbParticlesClick; i++) {
      addSingleParticle(details, color);
    }
  }

  void addSingleParticle(PointerEvent details, Color color) {
    double x = details.position.dx;
    double y = details.position.dy;
    double speedX = Random().nextDouble() * 30 - 15;
    double speedY = Random().nextDouble() * 30 - 15;
    setState(() {
      widget._particles.add(Particle(x, y, speedX, speedY, color));
    });
  }

  void addParticlesDrag(PointerEvent details) {
    if (!isPlaying) return;
    Color color = Color.fromARGB(255, Random().nextInt(255),
        Random().nextInt(255), Random().nextInt(255));
    for (int i = 0; i < ParticleEngine.nbParticlesDrag; i++) {
      addSingleParticle(details, color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Particles Engine',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            backgroundColor: Colors.black,
            body: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return Stack(children: [
                    Listener(
                      onPointerDown: (details) {
                        addParticlesClick(details);
                      },
                      onPointerMove: (details) {
                        addParticlesDrag(details);
                      },
                      child: CustomPaint(
                        painter: vueParticle = VueParticle(widget._particles),
                        child: Container(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: icon,
                        color: Colors.white,
                        onPressed: () {
                          changeIcon();
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.replay),
                        color: Colors.white,
                        onPressed: () {
                          replay();
                        },
                      ),
                    ),
                  ]);
                })));
  }
}

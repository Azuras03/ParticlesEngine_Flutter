import 'dart:math';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:particlesengine/model/particle.dart';
import 'package:particlesengine/vue/particle_settings.dart';
import 'package:particlesengine/vue/vue_particle.dart';

import '../model/explosion.dart';

class ParticleEngine extends StatefulWidget {
  final List<Particle> _particles = [];
  final List<Explosion> _explosions = [];
  static double gravity = 0.5;
  static double friction = 0.99;
  static double maxTime = 5;
  static double particleSize = 10;
  static int nbParticlesClick = 20;
  static int nbParticlesDrag = 2;
  static double timeExplosion = 1;
  static double explosionSize = 100;

  ParticleEngine({super.key});

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void replay() {
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
    addSingleExplosion(details, color, ParticleEngine.explosionSize);
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

  void addSingleExplosion(
      PointerEvent details, Color color, double explosionSize) {
    double x = details.position.dx;
    double y = details.position.dy;
    setState(() {
      widget._explosions.add(Explosion(x, y, explosionSize, color));
    });
  }

  void addParticlesDrag(PointerEvent details) {
    if (!isPlaying) return;
    Color color = Color.fromARGB(255, Random().nextInt(255),
            Random().nextInt(255), Random().nextInt(255))
        .withOpacity(0.5);
    addSingleExplosion(details, color, ParticleEngine.explosionSize / 2);
    for (int i = 0; i < ParticleEngine.nbParticlesDrag; i++) {
      addSingleParticle(details, color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    painter: vueParticle =
                        VueParticle(widget._particles, widget._explosions),
                    child: Container(),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ParticleSettings()));
                    },
                  ),
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay),
                          color: Colors.white,
                          onPressed: () {
                            replay();
                          },
                        ),
                        IconButton(
                          icon: icon,
                          color: Colors.white,
                          onPressed: () {
                            changeIcon();
                          },
                        ),
                      ],
                    )),
              ]);
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ));
  }
}

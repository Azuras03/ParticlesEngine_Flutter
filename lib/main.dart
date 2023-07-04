import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:particlesengine/model/Particle.dart';
import 'package:particlesengine/vue/VueParticle.dart';

void main() {
  List<Particle> particles = [];
  runApp(ParticleEngine(particles));
}

class ParticleEngine extends StatefulWidget {
  final List<Particle> _particles;

  const ParticleEngine(this._particles, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ParticleEngineState();
  }
}

class ParticleEngineState extends State<ParticleEngine> {
  bool _isPlaying = false;

  void update(double width, double height) {
    for (Particle particle in widget._particles) {
      particle.update(width, height);
    }
    purge();
  }

  void purge() {
    widget._particles.removeWhere((particle) => particle.time > 5);
  }

  void start(BuildContext context, bool isPlaying) {
    if (isPlaying) {
      return;
    }
    _isPlaying = true;
    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      setState(() {
        update(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height);
      });
    });
  }

  void replay() {
    setState(() {
      widget._particles.clear();
    });
  }

  void addParticlesClick(PointerEvent details) {
    for (int i = 0; i < 10; i++) {
      addSingleParticle(details);
    }
  }

  void addSingleParticle(PointerEvent details) {
    double x = details.position.dx;
    double y = details.position.dy;
    double speedX = Random().nextDouble() * 10 - 5;
    double speedY = Random().nextDouble() * 10 - 5;
    Color color = Color.fromARGB(255, Random().nextInt(255),
        Random().nextInt(255), Random().nextInt(255));
    setState(() {
      widget._particles.add(Particle(
          x,
          y,
          10,
          speedX,
          speedY,
          color));
    });
  }

  @override
  Widget build(BuildContext context) {
    start(context, _isPlaying);
    return MaterialApp(
      title: 'Particles Engine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Listener(
        onPointerDown: (details) {
          addParticlesClick(details);
        },
        child: Scaffold(
          body: RepaintBoundary(
            child: Stack(
              children: [
                ...widget._particles.map((particle) => VueParticle(particle)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

import 'package:flutter/material.dart';
import 'package:particlesengine/model/particle.dart';
import 'package:particlesengine/vue/particle_settings.dart';
import 'package:particlesengine/vue/vue_particle.dart';

import '../model/explosion.dart';

class ParticleEngine extends StatefulWidget {
  final List<Particle> _particles = [];
  final List<Explosion> _explosions = [];
  final List<String> explosionPaths = ["sounds/explosion.wav", "sounds/explosion2.wav", "sounds/explosion3.wav"];
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
  final List<AudioPlayer> audioPlayerExplosion = [];
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

  Future<void> addParticlesClick(PointerEvent details) async {
    if (!isPlaying) return;
    vibrate(128, 100);
    playExplosionFile();
    Color color = Color.fromARGB(255, Random().nextInt(255),
        Random().nextInt(255), Random().nextInt(255));
    addSingleExplosion(details, color, ParticleEngine.explosionSize);
    for (int i = 0; i < ParticleEngine.nbParticlesClick; i++) {
      addSingleParticle(details, color);
    }
  }

  void addParticlesDrag(PointerEvent details) {
    if (!isPlaying) return;
    vibrate(50, 50);
    Color color = Color.fromARGB(255, Random().nextInt(255),
            Random().nextInt(255), Random().nextInt(255))
        .withOpacity(0.5);
    addSingleExplosion(details, color, ParticleEngine.explosionSize / 2);
    for (int i = 0; i < ParticleEngine.nbParticlesDrag; i++) {
      addSingleParticle(details, color);
    }
  }

  Future<void> vibrate(int amplitude, int duration) async {
    bool? hasAmplitude = await checkAmplitude();
    if (hasAmplitude != null && hasAmplitude) {
      Vibration.vibrate(amplitude: amplitude, duration: duration);
    }
  }

  Future<bool?> checkAmplitude() {
    return Vibration.hasAmplitudeControl();
  }

  void playExplosionFile() {
    Future<int> future = findUsableAudioPlayer();
    AudioPlayer audioChosen = AudioPlayer();
    future.then((value) => audioChosen = audioPlayerExplosion[value]);
    audioChosen.play(AssetSource(getExplosionPath()));
  }

  String getExplosionPath() {
    return widget.explosionPaths[Random().nextInt(widget.explosionPaths.length)];
  }

  Future<int> findUsableAudioPlayer() {
    for (int i = 0; i < audioPlayerExplosion.length; i++) {
      if (audioPlayerExplosion[i].state == PlayerState.stopped) {
        return Future.value(i);
      }
    }
    AudioPlayer audioPlayer = AudioPlayer();
    audioPlayerExplosion.add(audioPlayer);
    return Future.value(audioPlayerExplosion.length - 1);
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
                      Navigator.of(context).push(_createRoute(const ParticleSettings()));
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

  Route _createRoute(partSettings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          partSettings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //ScaleTransition
        var begin = 0.0;
        var end = 1.0;
        var tween = Tween(begin: begin, end: end);
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return ScaleTransition(
          scale: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}

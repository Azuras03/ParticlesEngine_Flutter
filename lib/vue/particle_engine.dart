import 'dart:convert';
import 'dart:io';
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
  static List<String> explosionPaths = [];
  static List<String> explosionPathsSelected = [];
  static double gravity = 0.5;
  static double friction = 0.99;
  static double maxTime = 3;
  static double particleSize = 10;
  static int nbParticlesClick = 20;
  static int nbParticlesDrag = 2;
  static double timeExplosion = 1;
  static double explosionSize = 100;
  static List<String> particleShapes = [
    "circle",
    "square",
    "triangle",
    "star",
    "flower"
  ];
  static String particleShape = "circle";
  static bool transformParticle = true;
  static bool trailParticle = false;
  static bool hapticFeedback = false;
  static List<Path> paths = [];

  static void drawAllPaths() {
    paths.clear();
    paths.add(drawSquare());
    paths.add(drawTriangle());
    paths.add(drawStar());
    paths.add(drawFlower());
    paths.add(drawCircle());
  }

  static Path drawCircle() {
    Path path = Path();
    path.addOval(Rect.fromCenter(
        center: const Offset(0, 0),
        width: particleSize,
        height: particleSize));
    return path;
  }

  static Path drawSquare() {
    Path path = Path();
    path.addRect(Rect.fromCenter(
        center: const Offset(0, 0),
        width: particleSize,
        height: particleSize));
    return path;
  }

  static Path drawTriangle() {
    Path path = Path();
    var size = particleSize;
    path.moveTo(0, -size / 2);
    path.lineTo(size / 2, size / 2);
    path.lineTo(-size / 2, size / 2);
    path.close();
    return path;
  }

  static Path drawStar() {
    Path path = Path();
    double rot = pi / 2 * 3;
    double x = 0;
    double y = 0;
    int spikes = 5;
    double step = pi / spikes;
    double size = particleSize;
    double innerRadius = size / 2;
    double outerRadius = size;
    path.moveTo(0, 0 - outerRadius);
    for (int i = 0; i < spikes; i++) {
      x = 0 + cos(rot) * outerRadius;
      y = 0 + sin(rot) * outerRadius;
      path.lineTo(x, y);
      rot += step;

      x = 0 + cos(rot) * innerRadius;
      y = 0 + sin(rot) * innerRadius;
      path.lineTo(x, y);
      rot += step;
    }
    path.close();
    return path;
  }

  static Path drawFlower() {
    Path path = Path();
    int numPetals = 5;
    double size = particleSize * 1.5;
    for (var n = 0; n < numPetals; n++) {
      var theta1 = ((pi * 2) / numPetals) * (n + 1);
      var theta2 = ((pi * 2) / numPetals) * (n);

      var x1 = (size * sin(theta1));
      var y1 = (size * cos(theta1));
      var x2 = (size * sin(theta2));
      var y2 = (size * cos(theta2));

      path.moveTo(0, 0);
      path.cubicTo(x1, y1, x2, y2, 0, 0);
    }

    path.close();
    return path;
  }

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
  bool vibrationSensor = false;

  @override
  void initState() {
    super.initState();
    setExplosionPaths();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 100000000),
        animationBehavior: AnimationBehavior.preserve);
    _controller.forward();
    _vibrationSensorVerif().then((value) => vibrationSensor = value);
    ParticleEngine.drawAllPaths();
  }

  Future<bool> _vibrationSensorVerif() async {
    return Platform.isAndroid || Platform.isIOS;
  }

  void setExplosionPaths() async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final sounds = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('assets/sounds'));
    ParticleEngine.explosionPaths.clear();
    ParticleEngine.explosionPathsSelected.clear();
    for (String sound in sounds) {
      ParticleEngine.explosionPaths.add(sound.split("assets/")[1]);
      if (sound.contains("explosion")) {
        ParticleEngine.explosionPathsSelected.add(sound.split("assets/")[1]);
      }
    }
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

  void changeIconAnimation() {
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

  void addParticlesClick(PointerEvent details) async {
    if (!isPlaying) return;
    vibrate(128, 100);
    if(ParticleEngine.explosionPathsSelected.isNotEmpty) playExplosionFile();
    Color color = Color.fromARGB(255, Random().nextInt(255),
        Random().nextInt(255), Random().nextInt(255));
    addSingleExplosion(details, color, ParticleEngine.explosionSize);
    for (int i = 0; i < ParticleEngine.nbParticlesClick; i++) {
      addSingleParticle(details, color);
    }
  }

  void addParticlesDrag(PointerEvent details) {
    if (!isPlaying) return;
    if (ParticleEngine.hapticFeedback) vibrate(50, 50);
    Color color = Color.fromARGB(255, Random().nextInt(255),
            Random().nextInt(255), Random().nextInt(255))
        .withOpacity(0.5);
    addSingleExplosion(details, color, ParticleEngine.explosionSize / 2);
    for (int i = 0; i < ParticleEngine.nbParticlesDrag; i++) {
      addSingleParticle(details, color);
    }
  }

  void vibrate(int amplitude, int duration) async {
    if (!vibrationSensor) return;
    Vibration.vibrate(amplitude: amplitude, duration: duration);
  }

  void playExplosionFile() {
    Future<int> future = findUsableAudioPlayer();
    AudioPlayer audioChosen = AudioPlayer();
    future.then((value) => audioChosen = audioPlayerExplosion[value]);
    audioChosen.play(AssetSource(getExplosionPath()));
  }

  String getExplosionPath() {
    return ParticleEngine.explosionPathsSelected[
        Random().nextInt(ParticleEngine.explosionPathsSelected.length)];
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
        body: Stack(
          children: [
            AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return Listener(
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
                  );
                }),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context)
                      .push(_createRoute(const ParticleSettings()));
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
                        changeIconAnimation();
                      },
                    ),
                  ],
                )),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ));
  }

  Route _createRoute(partSettings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => partSettings,
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

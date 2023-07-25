import 'package:flutter/material.dart';
import 'package:particlesengine/vue/particle_engine.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF000000),
              ),
              child: const Center(
                child: Text(
                  'Particles Engine',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(_createRoute(ParticleEngine()));
                },
                child: const Text('Start'))
          ].animate(interval: const Duration(milliseconds: 300))
              .scale(curve: Curves.easeOutQuart, duration: const Duration(milliseconds: 1000))
            .slideY(begin: 100, end: 0, curve: Curves.easeOutQuart, duration: const Duration(milliseconds: 1000)),
        ),
      ),
    );
  }
}

Route _createRoute(page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

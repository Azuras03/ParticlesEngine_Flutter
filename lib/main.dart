import 'package:flutter/material.dart';
import 'package:particlesengine/vue/home.dart';
import 'package:particlesengine/vue/particle_engine.dart';

import 'model/particle.dart';

void main() {
  runApp(const HomeApp());
}

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Particles Engine',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Home());
  }
}

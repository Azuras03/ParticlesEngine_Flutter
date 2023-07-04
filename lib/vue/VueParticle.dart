import 'package:flutter/material.dart';
import 'package:particlesengine/model/Particle.dart';

class VueParticle extends StatelessWidget {
  final Particle _particle;

  const VueParticle(this._particle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: _particle.x,
        top: _particle.y,
      child: Container(
        width: _particle.size,
        height: _particle.size,
        decoration: BoxDecoration(
          color: _particle.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

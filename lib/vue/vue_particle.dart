import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:particlesengine/vue/particle_engine.dart';
import 'package:particlesengine/model/particle.dart';

import '../model/explosion.dart';

class VueParticle extends CustomPainter {
  final List<Particle> _particles;
  final List<Explosion> _explosions;

  const VueParticle(this._particles, this._explosions);

  @override
  void paint(Canvas canvas, Size size) {
    updateParticles(size.width, size.height);
    updateExplosions();
    drawExplosions(canvas, size);
    drawParticles(canvas, size);
  }

  void drawParticles(Canvas canvas, Size size) {
    for (Particle particle in _particles) {
      canvas.save();
      canvas.translate(particle.x, particle.y);
      double rotation = atan2(particle.speedY, particle.speedX);
      canvas.rotate(rotation + pi / 2);
      canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(0, 0),
              width: particle.size,
              height: particle.size + particle.speedX.abs() * 2),
          Paint()
            ..color = particle.color.withOpacity(
                (ParticleEngine.maxTime - particle.time) /
                    ParticleEngine.maxTime));
      canvas.restore();
    }
  }

  void updateParticles(double width, double height) {
    for (Particle particle in _particles) {
      particle.update(width, height);
    }
    purge();
  }

  void updateExplosions() {
    for (Explosion explosion in _explosions) {
      explosion.update();
    }
    purgeExplosions();
  }

  void purge() {
    _particles.removeWhere((particle) => !particle.good);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawExplosions(Canvas canvas, Size size) {
    for (Explosion explosion in _explosions) {
      double radius = explosion.size*explosion.time/ParticleEngine.timeExplosion;
      canvas.drawCircle(Offset(explosion.x, explosion.y), radius,
          Paint()
            ..shader = RadialGradient(colors: [
              explosion.color,
              explosion.color.withOpacity(0.0)
            ]).createShader(Rect.fromCircle(
                center: Offset(explosion.x, explosion.y),
                radius: radius))
            ..blendMode = BlendMode.plus);
    }
  }

  void purgeExplosions() {
    _explosions.removeWhere((explosion) => !explosion.good);
  }
}

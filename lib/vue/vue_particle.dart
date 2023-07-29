import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:particlesengine/vue/particle_engine.dart';
import 'package:particlesengine/model/particle.dart';

import '../model/explosion.dart';

class VueParticle extends CustomPainter {
  final List<Particle> _particles;
  final List<Explosion> _explosions;

  VueParticle(this._particles, this._explosions);

  @override
  void paint(Canvas canvas, Size size) {
    drawExplosions(canvas, size);
    drawParticles(canvas, size);
  }

  void drawParticles(Canvas canvas, Size size) {
    Path chosenPath;
    chosenPath = determineShapeFunction();
    purge();
    for (Particle particle in _particles) {
      particle.update(size.width, size.height);
      if (!particle.good) {
        continue;
      }
      drawPathParticle(particle, canvas, chosenPath);
    }
  }

  void drawPathParticle(Particle particle, Canvas canvas, Path chosenPath) {
    canvas.save();
    transformCanvas(canvas, particle);
    double opacity =
        (ParticleEngine.maxTime - particle.time) / ParticleEngine.maxTime;
    if (ParticleEngine.transformParticle) chosenPath = transformPath(particle, chosenPath);
    if (ParticleEngine.trailParticle) addTrailParticle(canvas, particle, opacity, chosenPath);
    canvas.drawPath(
        chosenPath, Paint()..color = particle.color.withOpacity(opacity));
    canvas.restore();
  }

  void addTrailParticle(Canvas canvas, Particle particle, double opacity, Path chosenPath) {
    double speedXTimesTwo = particle.speedX.abs() * 2;
    for (int i = 1; i < 3; i++) {
      canvas.save();
      canvas.translate(0,speedXTimesTwo * i);
      canvas.drawPath(chosenPath,
          Paint()..color = particle.color.withOpacity(opacity / (2 * i)));
      canvas.restore();
    }
  }

  void transformCanvas(Canvas canvas, Particle particle) {
    canvas.translate(particle.x, particle.y);
    double rotation = atan2(particle.speedY, particle.speedX);
    canvas.rotate(rotation + pi / 2);
  }

  Path transformPath(Particle particle, Path path) {
    double abs = particle.speedX.abs() / 4;
    if (abs < 1 && abs > -1) {
      abs = 1;
    }
    Float64List matrix4 = Float64List.fromList(
        [1, 0, 0, 0, 0, abs, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
    return path.transform(matrix4);
  }

  determineShapeFunction() {
    switch (ParticleEngine.particleShape) {
      case "square":
        return ParticleEngine.paths[0];
      case "triangle":
        return ParticleEngine.paths[1];
      case "star":
        return ParticleEngine.paths[2];
      case "flower":
        return ParticleEngine.paths[3];
      default:
        return ParticleEngine.paths[4];
    }
  }

  void purge() {
    _particles.removeWhere((particle) => !particle.good);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void drawExplosions(Canvas canvas, Size size) {
    purgeExplosions();
    for (Explosion explosion in _explosions) {
      explosion.update();
      double radius =
          explosion.size * explosion.time / ParticleEngine.timeExplosion;
      canvas.drawCircle(
          Offset(explosion.x, explosion.y),
          radius,
          Paint()
            ..shader = RadialGradient(
                    colors: [explosion.color, explosion.color.withOpacity(0.0)])
                .createShader(Rect.fromCircle(
                    center: Offset(explosion.x, explosion.y), radius: radius))
            ..blendMode = BlendMode.plus);
    }
  }

  void purgeExplosions() {
    _explosions.removeWhere((explosion) => !explosion.good);
  }
}

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
  final List<List<Particle>> _particlesLastFrames = [[], [], []];
  final List<Explosion> _explosions;

  VueParticle(this._particles, this._explosions);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.restore();
    drawExplosions(canvas, size);
    drawParticles(canvas, size);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
  }

  void drawParticles(Canvas canvas, Size size) {
    Path chosenPath;
    chosenPath = determineShapeFunction()(canvas);
    purge();
    for (Particle particle in _particles) {
      if (!particle.good) {
        continue;
      }
      drawPathParticle(particle, size, canvas, chosenPath);
    }
  }

  void drawPathParticle(
      Particle particle, Size size, Canvas canvas, Path chosenPath) {
    double opacity =
        (ParticleEngine.maxTime - particle.time) / ParticleEngine.maxTime;
    particle.update(size.width, size.height);
    canvas.save();
    transformCanvas(canvas, particle);
    if (ParticleEngine.transformParticle) chosenPath = highDetailTransformPath(particle, chosenPath);
    if (ParticleEngine.trailParticle) addTrailParticle(canvas, particle, opacity, chosenPath);
    canvas.drawPath(
        chosenPath, Paint()..color = particle.color.withOpacity(opacity));
    canvas.restore();
  }

  void addTrailParticle(Canvas canvas, Particle particle, double opacity, Path chosenPath) {
    double speedXTimesTwo = particle.speedX * 2;
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

  Path highDetailTransformPath(Particle particle, Path path) {
    double abs = 1;
    if (particle.speedX > 1 || particle.speedX < -1) {
      abs = particle.speedX.abs() / 2;
    }
    Float64List matrix4 = Float64List.fromList(
        [1, 0, 0, 0, 0, abs, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
    return path.transform(matrix4);
  }

  determineShapeFunction() {
    switch (ParticleEngine.particleShape) {
      case "square":
        return drawSquare;
      case "triangle":
        return drawTriangle;
      case "star":
        return drawStar;
      case "flower":
        return drawFlower;
      default:
        return drawCircle;
    }
  }

  Path drawCircle(Canvas canvas) {
    Path path = Path();
    path.addOval(Rect.fromCenter(
        center: const Offset(0, 0),
        width: ParticleEngine.particleSize,
        height: ParticleEngine.particleSize));
    return path;
  }

  Path drawSquare(Canvas canvas) {
    Path path = Path();
    path.addRect(Rect.fromCenter(
        center: const Offset(0, 0),
        width: ParticleEngine.particleSize,
        height: ParticleEngine.particleSize));
    return path;
  }

  Path drawTriangle(Canvas canvas) {
    Path path = Path();
    var size = ParticleEngine.particleSize;
    path.moveTo(0, -size / 2);
    path.lineTo(size / 2, size / 2);
    path.lineTo(-size / 2, size / 2);
    path.close();
    return path;
  }

  Path drawStar(Canvas canvas) {
    Path path = Path();
    double rot = pi / 2 * 3;
    double x = 0;
    double y = 0;
    int spikes = 5;
    double step = pi / spikes;
    double size = ParticleEngine.particleSize;
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

  Path drawFlower(Canvas canvas) {
    Path path = Path();
    int numPetals = 5;
    double size = ParticleEngine.particleSize * 1.5;
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

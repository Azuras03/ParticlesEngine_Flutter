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
    drawExplosions(canvas, size);
    drawParticles(canvas, size);
  }

  void drawParticles(Canvas canvas, Size size) {
    var chosenFunction;
    switch (ParticleEngine.particleShape) {
      case "circle":
        chosenFunction = drawCircle;
        break;
      case "square":
        chosenFunction = drawSquare;
        break;
      case "triangle":
        chosenFunction = drawTriangle;
        break;
      case "star":
        chosenFunction = drawStar;
        break;
      case "flower":
        chosenFunction = drawFlower;
        break;
    }
    purge();
    for (Particle particle in _particles) {
      if (!particle.good) {
        continue;
      }
      double opacity =
          (ParticleEngine.maxTime - particle.time) / ParticleEngine.maxTime;
      particle.update(size.width, size.height);
      canvas.save();
      canvas.translate(particle.x, particle.y);
      double rotation = atan2(particle.speedY, particle.speedX);
      canvas.rotate(rotation + pi / 2);
      chosenFunction(canvas, particle, opacity);
      canvas.restore();
    }
  }

  void drawCircle(Canvas canvas, Particle particle, double opacity) {
    canvas.drawOval(
        Rect.fromCenter(
            center: const Offset(0, 0),
            width: particle.size,
            height: particle.size + particle.speedX.abs() * 2),
        Paint()..color = particle.color.withOpacity(opacity));
  }

  void drawSquare(Canvas canvas, Particle particle, double opacity) {
    canvas.drawRect(
        Rect.fromCenter(
            center: const Offset(0, 0),
            width: particle.size,
            height: particle.size + particle.speedX.abs() * 2),
        Paint()..color = particle.color.withOpacity(opacity));
  }

  void drawTriangle(Canvas canvas, Particle particle, double opacity) {
    Path path = Path();
    path.moveTo(0, -particle.size / 2);
    path.lineTo(particle.size / 2 + particle.speedX.abs(), particle.size / 2);
    path.lineTo(-particle.size / 2 - particle.speedX.abs(), particle.size / 2);
    path.close();
    canvas.drawPath(path, Paint()..color = particle.color.withOpacity(opacity));
  }

  void drawStar(Canvas canvas, Particle particle, double opacity) {
    Path path = Path();
    double rot = pi / 2 * 3;
    double x = particle.x;
    double y = particle.y;
    int spikes = 5;
    double step = pi / spikes;
    double innerRadius = particle.size / 2;
    double outerRadius = particle.size;
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
    path.lineTo(0, 0 - outerRadius);
    path.close();
    canvas.drawPath(path, Paint()..color = particle.color.withOpacity(opacity));
  }

  void drawFlower(Canvas canvas, Particle particle, double opacity) {
    Path path = Path();
    int numPetals = 5;
    for (var n = 0; n < numPetals; n++) {
      var theta1 = ((pi * 2) / numPetals) * (n + 1);
      var theta2 = ((pi * 2) / numPetals) * (n);

      var x1 = (particle.size * sin(theta1));
      var y1 = (particle.size * cos(theta1));
      var x2 = (particle.size * sin(theta2));
      var y2 = (particle.size * cos(theta2));

      path.moveTo(0, 0);
      path.cubicTo(x1, y1, x2, y2, 0, 0);
    }

    path.close();
    canvas.drawPath(path, Paint()..color = particle.color.withOpacity(opacity));
  }

  void purge() {
    _particles.removeWhere((particle) => !particle.good);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
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

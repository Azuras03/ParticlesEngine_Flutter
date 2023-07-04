import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:particlesengine/model/Particle.dart';

class VueParticle extends CustomPainter {
  final List<Particle> _particles;

  const VueParticle(this._particles);

  @override
  void paint(Canvas canvas, Size size) {
    update(size.width, size.height);
    for (Particle particle in _particles) {
      canvas.save();
      canvas.translate(particle.x, particle.y);
      double rotation = atan2(particle.speedY, particle.speedX);
      canvas.rotate(rotation + pi / 2);
      canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(0, 0),
              width: particle.size,
              height: particle.size+particle.speedX.abs()/2),
          Paint()..color = particle.color);
      canvas.restore();
    }
  }

  void update(double width, double height) {
    for (Particle particle in _particles) {
      particle.update(width, height);
    }
    purge();
  }

  void purge() {
    _particles.removeWhere((particle) => !particle.good);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

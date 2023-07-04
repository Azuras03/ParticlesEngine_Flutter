import 'dart:ui';

import 'package:particlesengine/main.dart';

class Particle {

  double x;
  double y;
  late double size;
  double initialSpeedX;
  double initialSpeedY;
  late double speedX = 0;
  late double speedY = 0;
  Color color;
  bool good = true;
  late double time;

  Particle(this.x, this.y,
      this.initialSpeedX, this.initialSpeedY, this.color) {
    size = ParticleEngine.size;
    speedX = initialSpeedX;
    speedY = initialSpeedY;
    time = 0;
  }

  void update(double width, double height) {
    x += speedX;
    y += speedY;
    speedY += ParticleEngine.gravity;
    speedY *= ParticleEngine.friction;
    speedX *= ParticleEngine.friction;
    time += 0.01;
    if (time > ParticleEngine.maxTime) {
      good = false;
    }
    bounce(width, height);
  }

  bool bounce(double width, double height) {
    bool bounced = false;
    if (x < 0 || x > width) {
      speedX = -speedX;
      bounced = true;
    }
    if (y < 0 || y > height) {
      speedY = -speedY;
      bounced = true;
    }
    return bounced;
  }
}
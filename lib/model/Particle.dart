import 'dart:ui';

class Particle {

  double x;
  double y;
  double size;
  double initialSpeedX;
  double initialSpeedY;
  Color color;
  double speedX = 0;
  double speedY = 0;
  double time = 0;

  double gravity = 0.1;
  double friction = 0.99;

  Particle(this.x, this.y, this.size,
      this.initialSpeedX, this.initialSpeedY, this.color) {
    speedX = initialSpeedX;
    speedY = initialSpeedY;
  }

  void update(double width, double height) {
    x += speedX;
    y += speedY;
    speedY += gravity;
    speedY *= friction;
    speedX *= friction;
    time += 0.01;
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
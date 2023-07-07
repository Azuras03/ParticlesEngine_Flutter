import 'dart:ui';

import 'package:particlesengine/vue/particle_engine.dart';

class Explosion {

  double x;
  double y;
  double size;
  Color color;
  late double time;
  late bool good = true;

  Explosion(this.x, this.y, this.size, this.color) {
    time = ParticleEngine.timeExplosion;
    if (time < 0) {
      time = 1;
    }
  }

  void update(){
    if (!good) {
      return;
    }
    time -= 0.01;
    if(time <= 0){
      good = false;
      return;
    }
  }
}
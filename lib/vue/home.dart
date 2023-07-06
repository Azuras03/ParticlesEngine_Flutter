import 'package:flutter/material.dart';
import 'package:particlesengine/vue/particleengine.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Particles Engine"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF000000),
                ),
                child: const Center(
                  child: Text(
                    'Particles Engine',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ParticleEngine()),
                  );
                },
                child: const Text('Start'))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';
import 'package:particlesengine/vue/particle_engine.dart';

class ParticleSettings extends StatefulWidget {
  const ParticleSettings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ParticleSettingsState();
  }
}

class _ParticleSettingsState extends State<ParticleSettings> {
  bool gravity = ParticleEngine.gravity != 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Paramètres des particules"),
        ),
        body: Column(children: [
          SwitchListTile(
            title: const Text("Gravité"),
            value: gravity,
            onChanged: (bool value) {
              setState(() {
                ParticleEngine.gravity = value ? 1 : 0;
                gravity = value;
              });
            },
          ),
          Slider(
            value: ParticleEngine.gravity,
            min: -10,
            max: 10,
            divisions: 20,
            label: ParticleEngine.gravity.toString(),
            onChanged: (double value) {
              setState(() {
                ParticleEngine.gravity = value;
              });
            },
          ),
          Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Taille des particules',
                ),
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  setState(() {
                    ParticleEngine.particleSize = double.parse(value);
                  });
                },
                initialValue: ParticleEngine.particleSize.toString(),
              ),
              const Text("Multiplicateur (Friction de l'air)"),
              Slider(
                value: ParticleEngine.friction,
                min: 0,
                max: 1,
                divisions: 100,
                label: ParticleEngine.friction.toString(),
                onChanged: (double value) {
                  setState(() {
                    ParticleEngine.friction = value;
                  });
                },
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                "Nombre de particules au clic",
                style: TextStyle(fontSize: 20),
              ),
              Slider(
                value: ParticleEngine.nbParticlesClick.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: ParticleEngine.nbParticlesClick.toString(),
                onChanged: (double value) {
                  setState(() {
                    ParticleEngine.nbParticlesClick = value.toInt();
                  });
                },
              ),
            ],
          ),
          Container(
            child: DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Forme des particules',
              ),
              value: ParticleEngine.particleShape,
              onChanged: (String? newValue) {
                setState(() {
                  ParticleEngine.particleShape = newValue!;
                });
              },
              items: ParticleEngine.particleShapes
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style: const TextStyle(
                        fontSize: 20,
                      )),
                );
              }).toList(),
            ),
          ),
          Column(
            children: [
              const Text(
                "Nombre de particules au drag",
                style: TextStyle(fontSize: 20),
              ),
              Slider(
                value: ParticleEngine.nbParticlesDrag.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: ParticleEngine.nbParticlesDrag.toString(),
                onChanged: (double value) {
                  setState(() {
                    ParticleEngine.nbParticlesDrag = value.toInt();
                  });
                },
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                "Sons des explosions",
                style: TextStyle(fontSize: 20),
              ),
              DropDownMultiSelect(
                onChanged: (List<String> values) {
                  setState(() {
                    ParticleEngine.explosionPathsSelected = values;
                  });
                },
                options: ParticleEngine.explosionPaths,
                selectedValues: ParticleEngine.explosionPathsSelected,
                whenEmpty: "Aucun son sélectionné",
              ),
            ],
          )
        ]),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.check),
          onPressed: () {
            Navigator.pop(context);
          },
        ));
  }
}

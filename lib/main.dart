import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const VirtualAquariumApp());
}

class VirtualAquariumApp extends StatelessWidget {
  const VirtualAquariumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Virtual Aquarium',
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  const AquariumScreen({super.key});

  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> {
  List<Fish> fishList = [];
  bool collisionEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Aquarium'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 300,
              height: 300,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                color: Colors.lightBlue[50],
              ),
              child: Stack(
                children: fishList.map((fish) => _buildFish(fish)).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text('Enable collision effects'),
                    Switch(
                      value: collisionEnabled,
                      onChanged: (value) {
                        setState(() {
                          collisionEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                FloatingActionButton(
                  onPressed: _addFish,
                  child: const Icon(Icons.add),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFish(Fish fish) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      left: fish.position.dx,
      top: fish.position.dy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: fish.growing ? 50 : 30,
        height: fish.growing ? 50 : 30,
        decoration: BoxDecoration(
          color: fish.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _addFish() {
    if (fishList.length < 10) {
      Fish newFish = Fish(
        position: Offset(
          Random().nextDouble() * 280,
          Random().nextDouble() * 280,
        ),
        color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        speed: Random().nextDouble() * 5 + 1,
        growing: true,
      );
      setState(() {
        fishList.add(newFish);
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          newFish.growing = false;
        });
      });
    }
  }
}

class Fish {
  Offset position;
  Color color;
  double speed;
  bool growing;

  Fish(
      {required this.position,
      required this.color,
      required this.speed,
      this.growing = false});
}

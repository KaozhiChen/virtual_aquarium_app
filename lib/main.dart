import 'package:flutter/material.dart';
import 'dart:math';
import 'helper.dart';

void main() {
  runApp(const AquariumApp());
}

class AquariumApp extends StatelessWidget {
  const AquariumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Aquarium',
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  const AquariumScreen({super.key});

  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double fishSpeed = 1.0;
  Color selectedColor = Colors.orange;
  List<Widget> fishList = [];
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.repeat();

    // load the date if restart
    _loadFishData();
  }

  // 加载鱼的数据
  Future<void> _loadFishData() async {
    final fishData = await dbHelper.loadFish();
    if (fishData.isNotEmpty) {
      setState(() {
        fishList.clear();
        for (var fish in fishData) {
          String colorString = fish['fish_color'];
          double speed = fish['fish_speed'];
          Color fishColor = _colorFromString(colorString);
          _addFish(color: fishColor, speed: speed);
        }
      });
    }
  }

  // save the data of fish
  Future<void> saveFishData() async {
    await dbHelper.clearFish();
    for (var fishWidget in fishList) {
      MovingFish fish = fishWidget as MovingFish;
      String colorString = _colorToString(fish.color);
      double speed = fish.speed;

      await dbHelper.saveFish(colorString, speed);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved!')),
    );
  }

  // add fish
  void _addFish({Color? color, double? speed}) {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(MovingFish(
          controller: _controller,
          color: color ?? selectedColor,
          speed: speed ?? fishSpeed,
        ));
      });
    }
  }

  // change color
  Color _colorFromString(String color) {
    switch (color) {
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _colorToString(Color color) {
    if (color == Colors.orange) return 'orange';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    return 'orange';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aquarium App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Aquarium container
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                color: Colors.lightBlueAccent,
              ),
              child: Stack(
                children: fishList,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _addFish(),
                  child: const Text('Add Fish'),
                ),
                ElevatedButton(
                  onPressed: saveFishData,
                  child: const Text('Save Settings'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // adjust speed and color
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Speed'),
                    Slider(
                      value: fishSpeed,
                      min: 0.5,
                      max: 5.0,
                      onChanged: (value) {
                        setState(() {
                          fishSpeed = value;
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Fish Color'),
                    DropdownButton<Color>(
                      value: selectedColor,
                      items: const [
                        DropdownMenuItem(
                          value: Colors.orange,
                          child: Text('Orange'),
                        ),
                        DropdownMenuItem(
                          value: Colors.blue,
                          child: Text('Blue'),
                        ),
                        DropdownMenuItem(
                          value: Colors.green,
                          child: Text('Green'),
                        ),
                      ],
                      onChanged: (Color? newColor) {
                        setState(() {
                          selectedColor = newColor!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Moving fish widget
class MovingFish extends StatefulWidget {
  final AnimationController controller;
  final Color color;
  final double speed;

  const MovingFish({
    super.key,
    required this.controller,
    required this.color,
    required this.speed,
  });

  @override
  _MovingFishState createState() => _MovingFishState();
}

class _MovingFishState extends State<MovingFish> {
  late double posX;
  late double posY;
  late double directionX;
  late double directionY;
  final double fishSize = 20;

  @override
  void initState() {
    super.initState();
    final random = Random();
    posX = random.nextDouble() * 280;
    posY = random.nextDouble() * 280;
    directionX = (random.nextDouble() * 2 - 1) * widget.speed;
    directionY = (random.nextDouble() * 2 - 1) * widget.speed;

    widget.controller.addListener(() {
      setState(() {
        posX += directionX;
        posY += directionY;

        if (posX <= 0 || posX >= 280 - fishSize) {
          directionX = -directionX;
        }
        if (posY <= 0 || posY >= 280 - fishSize) {
          directionY = -directionY;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: posX,
      top: posY,
      child: Container(
        width: fishSize,
        height: fishSize,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

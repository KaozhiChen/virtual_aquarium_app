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
  List<GlobalKey<MovingFishState>> fishKeys = [];
  final dbHelper = DatabaseHelper();
  bool collisionEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.repeat();

    // add a listener to detect collision
    _controller.addListener(_checkCollision);

    _loadFishData();
  }

  // check collision
  void _checkCollision() {
    if (!collisionEnabled) return;

    for (int i = 0; i < fishKeys.length; i++) {
      for (int j = i + 1; j < fishKeys.length; j++) {
        final fish1 = fishKeys[i].currentState;
        final fish2 = fishKeys[j].currentState;

        if (fish1 != null && fish2 != null) {
          // check if collision
          if ((fish1.posX - fish2.posX).abs() < 20 &&
              (fish1.posY - fish2.posY).abs() < 20) {
            fish1.changeDirection();
            fish2.changeDirection();
            // change color
            fish1.changeColor();
            fish2.changeColor();
          }
        }
      }
    }
  }

  // load fish data
  Future<void> _loadFishData() async {
    final fishData = await dbHelper.loadFish();
    if (fishData.isNotEmpty) {
      setState(() {
        fishList.clear();
        fishKeys.clear();
        for (var fish in fishData) {
          String colorString = fish['fish_color'];
          double speed = fish['fish_speed'];
          Color fishColor = _colorFromString(colorString);
          _addFish(color: fishColor, speed: speed);
        }
      });
    }
  }

  // save fish data
  Future<void> saveFishData() async {
    await dbHelper.clearFish();
    for (var fishKey in fishKeys) {
      final fishState = fishKey.currentState;
      if (fishState != null) {
        String colorString = _colorToString(fishState.color);
        double speed = fishState.speed;

        await dbHelper.saveFish(colorString, speed);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved!')),
    );
  }

  // add fish
  void _addFish({Color? color, double? speed}) {
    if (fishList.length < 10) {
      setState(() {
        GlobalKey<MovingFishState> fishKey = GlobalKey<MovingFishState>();
        fishKeys.add(fishKey);
        fishList.add(
          MovingFish(
            key: fishKey,
            controller: _controller,
            color: color ?? selectedColor,
            speed: speed ?? fishSpeed,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 fish allowed')),
      );
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

            // toggle for detecting collision
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Enable Collision:'),
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
          ],
        ),
      ),
    );
  }
}

// Moving fish widget with position and direction
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
  MovingFishState createState() => MovingFishState();
}

class MovingFishState extends State<MovingFish>
    with SingleTickerProviderStateMixin {
  late double posX;
  late double posY;
  late double directionX;
  late double directionY;
  final double fishSize = 20;
  late Color color;
  late double speed;

  // add scale controller
  late AnimationController scaleController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    //sacle animation
    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    scaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(
        parent: scaleController,
        curve: Curves.easeOut,
      ),
    );
    scaleController.forward();

    color = widget.color;
    speed = widget.speed;
    final random = Random();
    posX = random.nextDouble() * 280;
    posY = random.nextDouble() * 280;
    directionX = (random.nextDouble() * 2 - 1) * speed;
    directionY = (random.nextDouble() * 2 - 1) * speed;

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

  // change direction if collision happend
  void changeDirection() {
    directionX = -directionX;
    directionY = -directionY;
  }

  // change color when collision happend
  void changeColor() {
    setState(() {
      color = _randomColor();
    });
  }

  // change color randomly
  Color _randomColor() {
    final random = Random();
    int index = random.nextInt(3);
    switch (index) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: posX,
      top: posY,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          width: fishSize,
          height: fishSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

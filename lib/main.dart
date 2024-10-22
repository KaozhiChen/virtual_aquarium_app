import 'package:flutter/material.dart';
import 'dart:math';

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
  // Animation controller
  late AnimationController _controller;
  double fishSpeed = 1.0; // Speed factor
  Color selectedColor = Colors.orange;
  List<Widget> fishList = [];

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Start the animation loop
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to add a new fish
  void addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(MovingFish(
          controller: _controller,
          color: selectedColor,
          speed: fishSpeed,
        ));
      });
    }
  }

  // Function to save settings (to be implemented with local storage)
  void saveSettings() {}

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
                children: fishList, // The list of fish inside the aquarium
              ),
            ),

            const SizedBox(height: 20),

            // Buttons to add fish and save settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: addFish, // Add fish functionality
                  child: const Text('Add Fish'),
                ),
                ElevatedButton(
                  onPressed: saveSettings, // Save settings functionality
                  child: const Text('Save Settings'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sliders and dropdowns for settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Speed slider
                Column(
                  children: [
                    const Text('Speed'),
                    Slider(
                      value: fishSpeed,
                      min: 0.5,
                      max: 5.0,
                      onChanged: (value) {
                        setState(() {
                          fishSpeed = value; // Update fish speed
                        });
                      },
                    ),
                  ],
                ),

                // Color dropdown
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

  const MovingFish(
      {super.key,
      required this.controller,
      required this.color,
      required this.speed});

  @override
  _MovingFishState createState() => _MovingFishState();
}

class _MovingFishState extends State<MovingFish> {
  // Random initial positions and movement directions
  late double posX;
  late double posY;
  late double directionX;
  late double directionY;
  final double fishSize = 20;

  @override
  void initState() {
    super.initState();
    // Initialize random position and movement direction
    final random = Random();
    posX = random.nextDouble() * 280;
    posY = random.nextDouble() * 280;
    directionX =
        (random.nextDouble() * 2 - 1) * widget.speed; // Random direction X
    directionY =
        (random.nextDouble() * 2 - 1) * widget.speed; // Random direction Y

    // Add animation listener to update fish position
    widget.controller.addListener(() {
      setState(() {
        posX += directionX;
        posY += directionY;

        // Check for collision with the aquarium boundaries
        if (posX <= 0 || posX >= 280 - fishSize) {
          directionX = -directionX; // Reverse direction on X axis
        }
        if (posY <= 0 || posY >= 280 - fishSize) {
          directionY = -directionY; // Reverse direction on Y axis
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

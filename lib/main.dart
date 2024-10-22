import 'package:flutter/material.dart';

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

class _AquariumScreenState extends State<AquariumScreen> {
  // Variables for fish settings
  double fishSpeed = 1.0;
  Color selectedColor = Colors.orange;
  List<Widget> fishList = [];

  // Function to add a new fish
  void addFish() {
    setState(() {
      fishList.add(Positioned(
        left: 50.0, // Example starting position
        top: 100.0, // Example starting position
        child: FishWidget(color: selectedColor),
      ));
    });
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
                          fishSpeed = value;
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

// Fish widget (can be customized with animations or images later)
class FishWidget extends StatelessWidget {
  final Color color;

  const FishWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

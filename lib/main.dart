import 'package:cosmos/fun_facts.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'planets.dart';
import 'quiz_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmos Home',
      home: const MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  // variables for the animation
  late AnimationController _controller;
  List<Offset>? _starPositions;

  @override
  void initState() {
    super.initState();
    // Creates a loop that repeats every 3 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers to save memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This generates 100 random positions only ONCE
    _starPositions ??= List.generate(100, (i) => Offset(
      math.Random().nextDouble() * MediaQuery.of(context).size.width,
      math.Random().nextDouble() * MediaQuery.of(context).size.height,
    ));

    return Stack(
      children : [
        //Layer 1: starry background image
        Positioned.fill(child: Image.asset("assets/space-bg.jpg", fit: BoxFit.cover)),

        //Layer 2: shooting star animation
        // AnimatedBuilder tells Flutter to redraw the painter every time the controller moves
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: TwinkleStarPainter(
                _controller.value * 2 * math.pi, // Sends the current time/value to the painter
                _starPositions!,
              ),
              size: Size.infinite,
            );
          },
        ),

      // LAYER 3:  UI (The Scaffold)
        Scaffold(
          backgroundColor: Colors.transparent, // CRITICAL: Makes the layers behind visible
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                //header
                const Text(
                  "COSMOS",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 5.0
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Explore the solar system!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 10), // Reduced space slightly for a better fit
                // 3D Orbiting Planets Widget
                const OrbitingPlanetsWidget(),

                const SizedBox(height: 60),

                // Friendly Rounded Buttons
                _buildMenuButton("Explore Planets", Colors.blue, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PlanetList() //this tell flutter to open class PlanetList in planets.dart file
                  ),
                  );
                }),
                _buildMenuButton("Fun Facts", Colors.orange, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FunFactsScreen()),
                  );
                }),
                _buildMenuButton("Quiz", Colors.purple, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuizSelectionPage()
                      ),
                  );
                }),
                ],
            ),
           ),
        ),
      ],
    );
  }

  // Helper method to create colorful rounded buttons
  Widget _buildMenuButton(String label, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 65,
          width: double.infinity,
          decoration: BoxDecoration(
            // 1. Transparent "Glass" fill
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            // 2. Glowing border that matches the theme
            border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 2
            ),
            // 3. Subtle shadow for depth
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TwinkleStarPainter extends CustomPainter {
  final double animationValue; // This value changes constantly
  final List<Offset> starPositions;

  TwinkleStarPainter(this.animationValue, this.starPositions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = math.Random(42); // Seeded so stars don't jump positions

    for (var pos in starPositions) {
      // Use math.sin to create a smooth fading in and out effect
      double opacity = (math.sin(animationValue + random.nextDouble() * 10) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawCircle(pos, random.nextDouble() * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



class OrbitingPlanetsWidget extends StatefulWidget {
  const OrbitingPlanetsWidget({super.key});

  @override
  State<OrbitingPlanetsWidget> createState() => _OrbitingPlanetsWidgetState();
}

class _OrbitingPlanetsWidgetState extends State<OrbitingPlanetsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  double zoom = 0.8; // Started slightly zoomed out to fit more planets
  double rotation = 0.0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Slower overall loop
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // Increased height to accommodate outer planets
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            zoom = details.scale.clamp(0.5, 1.5);
            rotation += details.focalPointDelta.dx * 0.002;
          });
        },
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Center(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(zoom)
                  ..rotateY(rotation)
                  ..rotateX(0.2), // Slight tilt for 3D feel
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _sun(),
                    // Orbit Rings
                    _orbitRing(50), _orbitRing(80), _orbitRing(110),
                    _orbitRing(140), _orbitRing(200), _orbitRing(260),

                    // Planets with Images & Unique Speeds
                    // Speed multiplier: higher = faster
                    _planet("Mercury", "assets/mercury.jpg", 50, 12, 4.1),
                    _planet("Venus", "assets/venus.jpg", 80, 18, 1.6),
                    _planet("Earth", "assets/earth.jpg", 110, 20, 1.0),
                    _planet("Mars", "assets/mars.jpg", 140, 16, 0.5),
                    _planet("Jupiter", "assets/jupiter.jpg", 200, 35, 0.2),
                    _planet("Saturn", "assets/saturn.jpg", 260, 30, 0.1),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sun() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(image: AssetImage("assets/sun.jpg"), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.6),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _orbitRing(double radius) {
    return Container(
      width: radius * 2, height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
    );
  }

  Widget _planet(String name, String assetPath, double radius, double size, double speed) {
    // Each planet gets its own angle calculation based on speed
    final angle = (controller.value * 2 * math.pi * speed);

    return Transform.translate(
      offset: Offset(radius * math.cos(angle), radius * math.sin(angle)),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: ClipOval(
          child: Image.asset(assetPath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
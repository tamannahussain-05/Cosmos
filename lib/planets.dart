import 'dart:math';
import 'package:flutter/material.dart';
import 'quiz_screen.dart'; //This allows planets.dart to see TwinkleStarPainter
import 'main.dart'; //To use twinkling star painter
import 'database.dart';

void main() {
  runApp(const MyApp());
}

// 1. Planet Data Model
class Planet {
  final String name;
  final String description;
  final String funFact;
  final String iconPath;
  final Color cardColor;
  final String distance;
  final String temperature;
  final String moons;
  final String dayLength;

  Planet({
  required this.name,
  required this.description,
  required this.funFact,
  required this.iconPath,
  required this.cardColor,
  required this.distance,
  required this.temperature,
  required this.moons,
  required this.dayLength,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cosmos Planets',
      theme: ThemeData.dark(),
      home: const PlanetList(),
    );
  }
}

// PLANET LIST ---
class PlanetList extends StatefulWidget {
  const PlanetList({super.key});
  @override
  State<PlanetList> createState() => _PlanetListState();
}

class _PlanetListState extends State<PlanetList> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Offset>? _starPositions;

  List<Planet> planets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Creates a loop that repeats every 3 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Load the data when the screen starts
    _loadData();
  }

  //loading function
  Future<void> _loadData() async {
    final List<Map<String, dynamic>> data = await PlanetDatabase.instance.fetchPlanets();
    setState(() {
      planets = data.map((json) => Planet(
        name: json['name'],
        description: json['description'],
        funFact: json['funFact'],
        iconPath: json['iconPath'],
        cardColor: Color(json['cardColor']), // Converts integer back to Color
        distance: json['distance'],
        temperature: json['temperature'],
        moons: json['moons'],
        dayLength: json['dayLength'],
      )).toList();
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers to save memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Generate star positions once for this specific screen
    _starPositions ??= List.generate(100, (i) => Offset(
      Random().nextDouble() * MediaQuery.of(context).size.width,
      Random().nextDouble() * MediaQuery.of(context).size.height,
    ));

    return Scaffold(
      // 2. Transparent background lets the Stack layers show through
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white)),
        ),
        title: const Text("Planets", style: TextStyle(color: Colors.white, fontSize: 30)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
      :Stack(
        children: [
          // LAYER 1: The Galaxy Image (Static)
          Positioned.fill(
            child: Image.asset("assets/space-bg.jpg", fit: BoxFit.cover),
          ),

          // LAYER 2: The Twinkling Stars (Animated)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: TwinkleStarPainter(
                  _controller.value * 2 * pi,
                  _starPositions!,
                ),
                size: Size.infinite,
              );
            },
          ),

          // LAYER 3: The UI (List of Planet Cards)
          // LAYER 3: Content (Conditional)
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ListView.builder(
            // This padding ensures the list starts BELOW the AppBar
            padding: const EdgeInsets.only(top: kToolbarHeight + 100, bottom: 20),
            itemCount: planets.length,
            itemBuilder: (context, index) {
              final planet = planets[index];
              return _buildPlanetCard(planet);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetCard(Planet planet) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FunFactPage(planet: planet, allPlanets: planets))
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Semi-transparent "Glass" effect
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          // Border matches the planet's unique theme color
          border: Border.all(color: planet.cardColor.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Hero(
                tag: planet.name,
                child: CircleAvatar(radius: 30, backgroundImage: AssetImage(planet.iconPath))
            ),
            const SizedBox(width: 20),
            Text(
                planet.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ],
        ),
      ),
    );
  }

}


//  Planet details PAGE ---
class FunFactPage extends StatefulWidget {
  final Planet planet;
  final List<Planet> allPlanets;
  const FunFactPage({super.key, required this.planet, required this.allPlanets});

  @override
  State<FunFactPage> createState() => _FunFactPageState();
}

class _FunFactPageState extends State<FunFactPage> with SingleTickerProviderStateMixin {
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
    // 1. Generate star positions once for this specific screen
    _starPositions ??= List.generate(100, (i) => Offset(
      Random().nextDouble() * MediaQuery.of(context).size.width,
      Random().nextDouble() * MediaQuery.of(context).size.height,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Stack(
        children: [
          // Matching Background Image
          Positioned.fill(child: Image.asset("assets/space-bg.jpg", fit: BoxFit.cover)),

          // Note: You can optionally add the AnimatedBuilder here too for twinkling stars
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: TwinkleStarPainter(
                  _controller.value * 2 * pi,
                  _starPositions!,
                ),
                size: Size.infinite,
              );
            },
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Hero(
                      tag: widget.planet.name,
                      child: CircleAvatar(radius: 90, backgroundImage: AssetImage(widget.planet.iconPath)),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.planet.name, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 15),
                      const Text("Overview", style: TextStyle(fontSize: 20, color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(widget.planet.description, style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.6)),
                      const SizedBox(height: 30),

                      //KeyFacts box
                      _buildDetailBox(
                        title: "Key Facts",
                        color: Colors.yellowAccent,
                        child: Column(
                          children: [
                            _buildInfoRow("Distance:", widget.planet.distance),
                            _buildInfoRow("Temp:", widget.planet.temperature),
                            _buildInfoRow("Moons:", widget.planet.moons),
                            _buildInfoRow("Day:", widget.planet.dayLength),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      //Did You Know Box
                      _buildDetailBox(
                        title: "Did You Know?",
                        color: Colors.greenAccent,
                        child: Text(widget.planet.funFact, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white)),
                     ),
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuizSelectionPage())),
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text("Go to Quiz", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBox({required String title, required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Refined for Harmony: Using planet color for the border
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: widget.planet.cardColor.withValues(alpha: 0.3)), // Dynamic border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

}



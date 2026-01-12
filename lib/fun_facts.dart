import 'package:flutter/material.dart';
import 'dart:math' as math; // Needed for stars
import 'planets.dart';
import 'main.dart'; // To use the TwinkleStarPainter class
import 'database.dart';


class FunFactsScreen extends StatefulWidget {
  const FunFactsScreen({super.key});

  @override
  State<FunFactsScreen> createState() => _FunFactsScreenState();
}

class _FunFactsScreenState extends State<FunFactsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Offset>? _starPositions;

  // SQL loading variables
  List<Planet> _planets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 3-second loop for the twinkling effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _loadData(); // Load planets from database
  }

  // Load from SQL
  Future<void> _loadData() async {
    final data = await PlanetDatabase.instance.fetchPlanets();
    setState(() {
      _planets = data.map((Map<String, dynamic> json) => Planet(
        name: json['name'] as String,
        description: json['description'] as String,
        funFact: json['funFact'] as String,
        iconPath: json['iconPath'] as String,
        cardColor: Color(json['cardColor'] as int),
        distance: json['distance'] as String,
        temperature: json['temperature'] as String,
        moons: json['moons'] as String,
        dayLength: json['dayLength'] as String,
      )).toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Cleanup memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generates star positions once per session
    _starPositions ??= List.generate(100, (i) => Offset(
      math.Random().nextDouble() * MediaQuery.of(context).size.width,
      math.Random().nextDouble() * MediaQuery.of(context).size.height,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent, // Background shows through
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Galactic Facts", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator(color: Colors.white))
      :Stack(
        children: [
          // Layer 1: Static Galaxy Image
          Positioned.fill(
            child: Image.asset(
              "assets/space-bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Layer 2: Animated Stars
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: TwinkleStarPainter(
                  _controller.value * 2 * math.pi,
                  _starPositions!,
                ),
                size: Size.infinite,
              );
            },
          ),
          // Layer 3: Glass Cards
          ListView.builder(
            padding: const EdgeInsets.only(top: 100, bottom: 20),
            itemCount: _planets.length,
            itemBuilder: (context, index) {
              return _buildFactCard(_planets[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard(Planet planet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(
        color: planet.cardColor.withValues(alpha: 0.1), // Glass effect
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: planet.cardColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: planet.cardColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/${planet.name.toLowerCase()}.jpg"),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                planet.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            planet.funFact,
            style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.8), height: 1.5),
          ),
        ],
      ),
    );
  }
}
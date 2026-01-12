import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart';
import 'database.dart';

class QuizSelectionPage extends StatefulWidget {
  const QuizSelectionPage({super.key});

  @override
  State<QuizSelectionPage> createState() => _QuizSelectionPageState();
}

class _QuizSelectionPageState extends State<QuizSelectionPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, //allows stars to go behind the appbar
      appBar: AppBar(
        title: const Text("Quiz Time !", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
      : Stack(
        children: [
          //1. starry background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/space-bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),


          //2. UI content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 250),

                const Text(
                  "Ready for a Mission?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Choose a quiz type to start",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 80), //space between text and button

                _quizCategory(context, "Multiple Choice", "perfect for beginners", Colors.purple, Icons.shuffle, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RandomPlanetQuiz()));
                }),
                _quizCategory(context, "True or False", "Quick yes or no questions", Colors.pink, Icons.check_circle, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TrueOrFalseQuiz()));
                }),

              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _quizCategory(BuildContext context, String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 37),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5,
                      ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  )
                ]),
                ],
              )

      ),
    );
  }
}

class TrueOrFalseQuiz extends StatefulWidget {
  const TrueOrFalseQuiz({super.key});
  @override
  State<TrueOrFalseQuiz> createState() => _TrueOrFalseQuizState();
}

class _TrueOrFalseQuizState extends State<TrueOrFalseQuiz> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Offset>? _starPositions;

  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _score = 0;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _loadQuizData(); // Start the SQL fetch
  }

  void _handleAnswer(String userChoice) {
    if (userChoice == _questions[_currentIndex].correctAnswer) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finish();
    }
  }

  void _finish() async {
    // Save Score to SQL
    await PlanetDatabase.instance.insertScore(QuizScore(
      score: _score,
      total: _questions.length,
      quizType: "True or False",
      date: DateTime.now(),
    ));

    if (!mounted) return;

    showDialog(context: context, builder: (c) => AlertDialog(
        title: const Text("Mission Complete!"),
        content: Text("Score: $_score/10"),
        actions: [TextButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text("Home"))]
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers to save memory
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    final data = await PlanetDatabase.instance.getRandomQuestions("True or False");
    setState(() {
      _questions = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    final currentQuestion = _questions[_currentIndex];

    _starPositions ??= List.generate(100, (i) => Offset(
      Random().nextDouble() * MediaQuery.of(context).size.width,
      Random().nextDouble() * MediaQuery.of(context).size.height,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white)),
        ),
        title: Text("Question ${_currentIndex + 1}/10", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Layer 1: Galaxy Image
          Positioned.fill(child: Image.asset("assets/space-bg.jpg", fit: BoxFit.cover)),

          // Layer 2: Twinkling Stars
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => CustomPaint(
              painter: TwinkleStarPainter(_controller.value * 2 * pi, _starPositions!),
              size: Size.infinite,
            ),
          ),

          // Layer 3: Quiz UI
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The Question "Glass" Card
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      currentQuestion.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, color: Colors.white, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      _answerButton("TRUE", Colors.green, "True"),
                      const SizedBox(width: 15),
                      _answerButton("FALSE", Colors.red, "False"),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerButton(String label, Color color, String choiceValue) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2), // Semi-transparent
          foregroundColor: Colors.white,
          side: BorderSide(color: color.withValues(alpha: 0.5), width: 2), // Glowing border
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () => _handleAnswer(choiceValue),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class RandomPlanetQuiz extends StatefulWidget {
  const RandomPlanetQuiz({super.key});
  @override
  State<RandomPlanetQuiz> createState() => _RandomPlanetQuizState();
}

class _RandomPlanetQuizState extends State<RandomPlanetQuiz> {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  // THE KEY: Fetching the 10 random questions from SQL
  Future<void> _loadQuizData() async {
    final data = await PlanetDatabase.instance.getRandomQuestions("Multiple Choice");
    setState(() {
      _questions = data;
      _isLoading = false;
    });
  }

  void _handleAnswer(String selectedOption) {
    if (selectedOption == _questions[_currentIndex].correctAnswer) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finish();
    }
  }

  void _finish() async {
    // SAVE SCORE TO DATABASE
    await PlanetDatabase.instance.insertScore(QuizScore(
      score: _score,
      total: _questions.length,
      quizType: "Multiple Choice",
      date: DateTime.now(),
    ));

    if (!mounted) return ;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Mission Complete!"),
        content: Text("Score: $_score/${_questions.length}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text("Home"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent, // Harmony: Transparent scaffold
      appBar: AppBar(
        title: Text("Question ${_currentIndex + 1}/10", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Background Layers
          Positioned.fill(child: Image.asset("assets/space-bg.jpg", fit: BoxFit.cover)),

          // 2. The Description Card
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05), // Glass effect
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      currentQuestion.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, color: Colors.white, height: 1.5),
                    ),
                  ),
                ),

                // 3. Build options from the quizQuestion object
                const SizedBox(height: 20),
                ...currentQuestion.options.map((option) => _buildOptionButton(option)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String optionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1), // Glassy button
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Colors.white24),
            ),
          ),
          onPressed: () => _handleAnswer(optionText),
            child: Text(optionText, style: const TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}




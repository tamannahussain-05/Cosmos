import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PlanetDatabase {
  static final PlanetDatabase instance = PlanetDatabase._init();
  static Database? _database;

  PlanetDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('planets_cosmos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Create the table structure for planets
    await db.execute('''
      CREATE TABLE planets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        funFact TEXT,
        iconPath TEXT,
        cardColor INTEGER, 
        distance TEXT,
        temperature TEXT,
        moons TEXT,
        dayLength TEXT
      )
    ''');

    // 2. Table structure for Questions
    await db.execute('''
    CREATE TABLE questions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question TEXT, correctAnswer TEXT,
      optionA TEXT, optionB TEXT, optionC TEXT,
      category TEXT
    )
  ''');

    // 3. Table structure for Scores
    await db.execute('''
    CREATE TABLE scores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      score INTEGER, total INTEGER, quizType TEXT, date TEXT
    )
  ''');

    // 2. Seed Data
    await _seedPlanets(db);
    await _seedQuestions(db);
  }


  // Database Actions

  Future<List<Map<String, dynamic>>> fetchPlanets() async {
    final db = await instance.database;
    return await db.query('planets');
  }


  // Gets 10 random questions for a specific quiz type
  Future<List<QuizQuestion>> getRandomQuestions(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'questions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'RANDOM()',
      limit: 10,
    );
    return result.map((json) => QuizQuestion.fromMap(json)).toList();
  }

  Future<void> insertScore(QuizScore score) async {
    final db = await instance.database;
    await db.insert('scores', score.toMap());
  }

  Future<List<QuizScore>> fetchScores() async {
    final db = await instance.database;
    final result = await db.query('scores', orderBy: 'date DESC');
    return result.map((json) => QuizScore.fromMap(json)).toList();
  }


  // Seeding Methods

  Future<void> _seedPlanets(Database db) async {
    final planetsToSeed = [
      {
        'name': 'Sun',
        'description': 'The star at the center of our Solar System. It provides the energy that supports life on Earth through nuclear fusion.',
        'funFact': 'The Sun is so big that about 1.3 million Earths could fit inside it!',
        'iconPath': 'assets/sun.jpg',
        'cardColor': Colors.orange.toARGB32(),
        'distance': '0 km',
        'temperature': '15,000,000°C',
        'moons': '0',
        'dayLength': '27 Earth Days',
      },
      {
        'name': 'Mercury',
        'description': 'The smallest planet and closest to the Sun. It has almost no atmosphere to trap heat.',
        'funFact': 'Mercury is not the hottest planet; Venus is!',
        'iconPath': 'assets/mercury.jpg',
        'cardColor': Colors.blueGrey.toARGB32(),
        'distance': '57.9 million km',
        'temperature': '167°C',
        'moons': '0',
        'dayLength': '58d 15h',
      },
      {
        'name': 'Venus',
        'description': "Earth's sister planet. Its toxic atmosphere traps heat, making it the hottest planet.",
        'funFact': "Venus spins clockwise—it's upside down!",
        'iconPath': 'assets/venus.jpg',
        'cardColor': Colors.amber.toARGB32(),
        'distance': '108.2 million km',
        'temperature': '464°C',
        'moons': '0',
        'dayLength': '243 Days',
      },
      {
        'name': 'Earth',
        'description': 'Our home planet. The only place in the universe with liquid water and life.',
        'funFact': 'Earth is the only known planet with life!',
        'iconPath': 'assets/earth.jpg',
        'cardColor': Colors.green.toARGB32(),
        'distance': '149.6 million km',
        'temperature': '15°C',
        'moons': '1',
        'dayLength': '24 hours',
      },
      {
        'name': 'Mars',
        'description': 'Known as the Red Planet. It is a cold desert world with polar ice caps and ancient riverbeds.',
        'funFact': 'Mars has the tallest volcano in the solar system!',
        'iconPath': 'assets/mars.jpg',
        'cardColor': Colors.red.toARGB32(),
        'distance': '227.9 million km',
        'temperature': '-65°C',
        'moons': '2',
        'dayLength': '24.6 hours',
      },
      {
        'name': 'Jupiter',
        'description': 'The largest planet in our system. A gas giant known for its massive storms,like the Great Red Spot.',
        'funFact': 'Jupiter contains twice the mass of all other planets combined!',
        'iconPath': 'assets/jupiter.jpg',
        'cardColor': Colors.brown.toARGB32(),
        'distance': '778.5 million km',
        'temperature': '-110°C',
        'moons': '95',
        'dayLength': '9.9 hours',
      },
      {
        'name': 'Saturn',
        'description': "The ringed planet. It is made up of hydrogen and helium, and It is so light it could float in water.",
        'funFact': "Saturn's rings are made of billions of chunks of ice and rock.",
        'iconPath': 'assets/saturn.jpg',
        'cardColor': Colors.blueAccent.toARGB32(),
        'distance': '1.4 billion km',
        'temperature': '-140°C',
        'moons': '146',
        'dayLength': '10.7 hours',
      },
      {
        'name': 'Uranus',
        'description': 'An ice giant that rotates on its side, nearly 90 degrees from the plane of its orbit.',
        'funFact': 'Uranus was the first planet found with the help of a telescope!',
        'iconPath': 'assets/uranus.jpg',
        'cardColor': Colors.cyanAccent.toARGB32(),
        'distance': '2.9 billion km',
        'temperature': '-195°C',
        'moons': '28',
        'dayLength': '17.2 hours',
      },
      {
        'name': 'Neptune',
        'description': 'The most distant major planet from the Sun. It is dark, cold,and windy.',
        'funFact': 'Neptune was found via math before it was seen!',
        'iconPath': 'assets/neptune.jpg',
        'cardColor': Colors.indigo.toARGB32(),
        'distance': '4.5 billion km',
        'temperature': '-201°C',
        'moons': '16',
        'dayLength': '16.1 hours',
      },
    ];
    for (var planet in planetsToSeed) {
      await db.insert('planets', planet);
    }
  }

  Future<void> _seedQuestions(Database db) async {
    final List<QuizQuestion> questions = [
      // --- 30 MULTIPLE CHOICE QUESTIONS ---
      QuizQuestion(question: 'Which is the largest planet?',
          correctAnswer: 'Jupiter',
          options: ['Jupiter', 'Saturn', 'Neptune'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet is known as the Red Planet?',
          correctAnswer: 'Mars',
          options: ['Mars', 'Venus', 'Jupiter'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'What is the hottest planet in our solar system?',
          correctAnswer: 'Venus',
          options: ['Mercury', 'Venus', 'Mars'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet has the most visible rings?',
          correctAnswer: 'Saturn',
          options: ['Saturn', 'Jupiter', 'Uranus'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet spins on its side?',
          correctAnswer: 'Uranus',
          options: ['Uranus', 'Neptune', 'Saturn'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'The Sun is a...',
          correctAnswer: 'Star',
          options: ['Planet', 'Star', 'Galaxy'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet is closest to the Sun?',
          correctAnswer: 'Mercury',
          options: ['Venus', 'Mercury', 'Earth'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'What is the Great Red Spot on Jupiter?',
          correctAnswer: 'A Storm',
          options: ['A Mountain', 'A Storm', 'A Desert'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet is called Earth’s Sister?',
          correctAnswer: 'Venus',
          options: ['Mars', 'Venus', 'Neptune'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet takes 165 years to orbit the Sun?',
          correctAnswer: 'Neptune',
          options: ['Uranus', 'Neptune', 'Saturn'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'What is the main gas in the Sun?',
          correctAnswer: 'Hydrogen',
          options: ['Oxygen', 'Hydrogen', 'Nitrogen'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet has the moon "Titan"?',
          correctAnswer: 'Saturn',
          options: ['Saturn', 'Jupiter', 'Mars'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Olympus Mons, the tallest volcano, is on...',
          correctAnswer: 'Mars',
          options: ['Earth', 'Venus', 'Mars'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet has the most moons?',
          correctAnswer: 'Saturn',
          options: ['Jupiter', 'Saturn', 'Uranus'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Galileo first saw this planet’s rings in 1610.',
          correctAnswer: 'Saturn',
          options: ['Saturn', 'Jupiter', 'Venus'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet is known as an Ice Giant?',
          correctAnswer: 'Uranus',
          options: ['Uranus', 'Mars', 'Mercury'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'How many planets are in our Solar System?',
          correctAnswer: '8',
          options: ['7', '8', '9'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'The Moon orbits which body?',
          correctAnswer: 'Earth',
          options: ['Sun', 'Earth', 'Mars'],
          category: 'Multiple Choice'),
      QuizQuestion(
          question: 'Which planet is named after the Roman god of war?',
          correctAnswer: 'Mars',
          options: ['Mars', 'Jupiter', 'Saturn'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'What is the smallest planet?',
          correctAnswer: 'Mercury',
          options: ['Mars', 'Mercury', 'Pluto'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'The asteroid belt is between Mars and...',
          correctAnswer: 'Jupiter',
          options: ['Jupiter', 'Earth', 'Saturn'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet has a day longer than its year?',
          correctAnswer: 'Venus',
          options: ['Venus', 'Mercury', 'Mars'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'What gives Mars its red color?',
          correctAnswer: 'Iron Oxide',
          options: ['Iron Oxide', 'Red Sand', 'Heat'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet has the strongest winds?',
          correctAnswer: 'Neptune',
          options: ['Jupiter', 'Neptune', 'Uranus'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Earth’s atmosphere is mostly...',
          correctAnswer: 'Nitrogen',
          options: ['Oxygen', 'Nitrogen', 'Carbon'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet was discovered by math?',
          correctAnswer: 'Neptune',
          options: ['Neptune', 'Uranus', 'Pluto'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'The distance light travels in a year is a...',
          correctAnswer: 'Light-year',
          options: ['Light-year', 'Solar-year', 'Parsec'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which planet has "Phobos" and "Deimos" moons?',
          correctAnswer: 'Mars',
          options: ['Jupiter', 'Mars', 'Saturn'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Saturn’s rings are mostly made of...',
          correctAnswer: 'Ice',
          options: ['Rock', 'Ice', 'Gas'],
          category: 'Multiple Choice'),
      QuizQuestion(question: 'Which is the densest planet?',
          correctAnswer: 'Earth',
          options: ['Jupiter', 'Earth', 'Mercury'],
          category: 'Multiple Choice'),

      // --- 30 TRUE OR FALSE QUESTIONS ---
      QuizQuestion(question: 'The Sun is a planet.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Saturn could float in water.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Mercury is the hottest planet.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Venus spins clockwise.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Mars has liquid water on its surface today.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Jupiter is a gas giant.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Uranus was the first planet found by telescope.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Neptune is smaller than Earth.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Pluto is currently a major planet.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'The Moon has no atmosphere.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Jupiter’s day is less than 10 hours long.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Venus is the only planet with no moons.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'A year on Mercury is 88 Earth days.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'The Milky Way is our galaxy.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Stars produce energy through fusion.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Mars is also known as the Blue Planet.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'The Sun’s core is hotter than its surface.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Saturn is the only planet with rings.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Uranus is an Ice Giant.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'The asteroid belt is between Earth and Mars.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Sound can travel through space.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Earth is about 4.5 billion years old.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Jupiter has 95 known moons.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Neptune is the furthest planet from the Sun.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'A day on Venus is longer than its year.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Comets are made of ice and dust.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Mercury has polar ice caps.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'Black holes have no gravity.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(question: 'The Great Red Spot is a mountain on Mars.',
          correctAnswer: 'False',
          options: ['True', 'False'],
          category: 'True or False'),
      QuizQuestion(
          question: 'A solar eclipse happens when the Moon is between Sun and Earth.',
          correctAnswer: 'True',
          options: ['True', 'False'],
          category: 'True or False'),
    ];

    for (var q in questions) {
      await db.insert('questions', {
        'question': q.question,
        'correctAnswer': q.correctAnswer,
        'optionA': q.options[0],
        'optionB': q.options[1],
        'optionC': q.options.length > 2 ? q.options[2] : '',
        'category': q.category,
      });
    }
  }

}



// Models

class QuizQuestion {
  final int? id;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String category;

  QuizQuestion({this.id, required this.question, required this.correctAnswer, required this.options, required this.category});

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'],
      question: map['question'],
      correctAnswer: map['correctAnswer'],
      options: [
        map['optionA'],
        map['optionB'],
        if (map['optionC'] != '') map['optionC'],
      ],
      category: map['category'],
    );
  }
}


// The Score Model
class QuizScore {
  final int? id;
  final int score;
  final int total;
  final String quizType;
  final DateTime date;

  QuizScore(
      {this.id, required this.score, required this.total, required this.quizType, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'total': total,
      'quizType': quizType,
      'date': date.toIso8601String(),
    };
  }

  factory QuizScore.fromMap(Map<String, dynamic> map) {
    return QuizScore(
      id: map['id'],
      score: map['score'],
      total: map['total'],
      quizType: map['quizType'],
      date: DateTime.parse(map['date']),
    );
  }
}
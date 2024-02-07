import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'quiz_history.dart'; // Import the quiz history page file
// import 'login_page.dart'; //    Import the login page file

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Quiz> _quizzes = []; // Initialize _quizzes with an empty list

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    final String url = 'https://raw.githubusercontent.com/su-resh/idpass/main/qnans.json'; // Replace with your JSON URL

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _quizzes = List<Quiz>.from(jsonData['quizzes'].map((quiz) => Quiz.fromJson(quiz)));
        });
      } else {
        throw Exception('Failed to fetch quiz data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _logout(BuildContext context) {
    // Perform logout actions here (e.g., clear user session data)
    // Navigate back to the login page
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Quiz History'),
              onTap: () {
                Navigator.pushNamed(context, '/quiz_history'); // Navigate to quiz history page
              },
            ),
            ListTile(
              title: Text('Logout'), // Logout button
              onTap: () {
                _logout(context); // Call _logout method
              },
            ),
          ],
        ),
      ),
      body: _quizzes.isNotEmpty // Check if _quizzes is not empty before building UI
          ? ListView.builder(
              itemCount: _quizzes.length,
              itemBuilder: (context, index) {
                final quiz = _quizzes[index];
                return QuizSection(quiz: quiz, isLast: index == _quizzes.length - 1);
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class Quiz {
  final String title;
  final List<Question> questions;

  Quiz({required this.title, required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      title: json['title'],
      questions: List<Question>.from(json['questions'].map((question) => Question.fromJson(question))),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctIndex;

  Question({required this.question, required this.options, required this.correctIndex});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
    );
  }
}

class QuizSection extends StatefulWidget {
  final Quiz quiz;
  final bool isLast;

  const QuizSection({required this.quiz, required this.isLast});

  @override
  _QuizSectionState createState() => _QuizSectionState();
}

class _QuizSectionState extends State<QuizSection> {
  List<String?> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.generate(widget.quiz.questions.length, (_) => null);
  }

  void _onOptionSelected(int index, String option) {
    setState(() {
      _selectedOptions[index] = option;
    });
  }

  void _submitQuiz() {
    int score = 0;
    for (int i = 0; i < _selectedOptions.length; i++) {
      if (_selectedOptions[i] == widget.quiz.questions[i].options[widget.quiz.questions[i].correctIndex]) {
        score++;
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Submitted'),
          content: Text('Your score: $score / ${widget.quiz.questions.length}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.quiz.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.quiz.questions.length,
            itemBuilder: (context, index) {
              final question = widget.quiz.questions[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(question.question),
                    ),
                    Column(
                      children: question.options.map((option) {
                        int optionIndex = question.options.indexOf(option);
                        return ListTile(
                          title: Text(option),
                          leading: Radio(
                            value: option,
                            groupValue: _selectedOptions[index],
                            onChanged: (value) {
                              _onOptionSelected(index, value.toString());
                            },
                          ),
                          onTap: () {
                            _onOptionSelected(index, option);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.isLast)
            Center(
              child: ElevatedButton(
                onPressed: _submitQuiz,
                child: Text('Submit'),
              ),
            ),
        ],
      ),
    );
  }
}

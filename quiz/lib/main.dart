// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart'; // Import the login page file
import 'quiz_history.dart'; // Import the quiz history page file

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Set initial route to '/login'
      routes: {
        '/login': (context) => LoginPage(), // Add route for login page
        '/quiz_history': (context) => QuizHistoryPage(), // Add route for quiz history page
      },
    );
  }
}

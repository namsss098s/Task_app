import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_exam/AuthScreen.dart';
import 'HomeScreen.dart'; // Import HomeScreen
import 'TaskScreen.dart';
import 'Profilescreen.dart';
import 'package:final_exam/Startscreen.dart';
import 'TaskHabitProvider.dart'; // Make sure to import TaskHabitProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(TaskHabitManagerApp()); // Launch TaskHabitManagerApp
}

class TaskHabitManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskHabitProvider(), // Provide TaskHabitProvider
      child: MaterialApp(
        title: 'Task & Habit Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/', // The initial route will be StartScreen
        routes: {
          '/': (context) => StartScreen(), // StartScreen as the first screen
          '/auth': (context) => Authscreen(), // Login or Sign-up screen
          '/home': (context) => HomeScreen(), // Main screen after login
          '/tasks': (context) => TaskScreen(),
          '/profile': (context) => ProfileScreen(),
        },
      ),
    );
  }
}

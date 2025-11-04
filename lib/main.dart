// lib/main.dart
import 'package:flutter/material.dart';
import 'app/views/home_page.dart';
import 'app/utils/habit.dart';
import 'app/utils/category.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicialmente vazios
    final List<Habit> initialHabits = [];
    final List<Category> initialCategories = [
      Category(name: 'Exercício', maxPoints: 100),
      Category(name: 'Leitura', maxPoints: 100),
      Category(name: 'Alimentação', maxPoints: 100),
      Category(name: 'Trabalho', maxPoints: 100),
      Category(name: 'Lazer', maxPoints: 100),
    ];

    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(
        initialHabits: initialHabits,
        initialCategories: initialCategories,
      ),
    );
  }
}

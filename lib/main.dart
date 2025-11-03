// lib/main.dart
import 'package:flutter/material.dart';
import 'app/views/home_page.dart';
import 'app/utils/habit.dart';
import 'app/utils/category.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Lista de hábitos inicial vazia
  List<Habit> habits = [];

  // Lista de categorias inicial (5 categorias de exemplo)
  List<Category> categories = [
    Category(name: 'Exercício', maxPoints: 100),
    Category(name: 'Leitura', maxPoints: 50),
    Category(name: 'Alimentação', maxPoints: 70),
    Category(name: 'Trabalho', maxPoints: 80),
    Category(name: 'Lazer', maxPoints: 60),
  ];

  // Função para atualizar hábitos
  void updateHabits(List<Habit> updated) {
    setState(() {
      habits = updated;
    });
  }

  // Função para atualizar categorias
  void updateCategories(List<Category> updated) {
    setState(() {
      categories = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(
        habits: habits,
        categories: categories,
        onHabitsChanged: updateHabits,
        onCategoriesChanged: updateCategories,
      ),
    );
  }
}

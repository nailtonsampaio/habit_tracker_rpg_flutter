// lib/app/views/home_page.dart
import 'package:flutter/material.dart';
import 'habits_page.dart';
import 'stats_page.dart';
import '../utils/habit.dart';
import '../utils/category.dart';

class HomePage extends StatefulWidget {
  final List<Habit> habits;
  final List<Category> categories;
  final Function(List<Habit>) onHabitsChanged;
  final Function(List<Category>) onCategoriesChanged;

  const HomePage({
    super.key,
    required this.habits,
    required this.categories,
    required this.onHabitsChanged,
    required this.onCategoriesChanged,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HabitsPage(
        habits: widget.habits,
        categories: widget.categories,
        onHabitsChanged: widget.onHabitsChanged,
        onCategoriesChanged: widget.onCategoriesChanged,
      ),
      StatsPage(
        habits: widget.habits,
        categories: widget.categories,
        onCategoriesChanged: widget.onCategoriesChanged,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Hábitos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Gráfico',
          ),
        ],
      ),
    );
  }
}

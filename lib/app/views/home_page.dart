import 'dart:async';
import 'package:flutter/material.dart';
import 'habits_page.dart';
import 'stats_page.dart';
import 'horizontal_bars_page.dart';
import 'habits_matrix_page.dart';
import '../utils/habit.dart' as utils;
import '../utils/category.dart' as cat;
import '../utils/habit_storage.dart';
import '../utils/category_storage.dart';

class HomePage extends StatefulWidget {
  final List<utils.Habit> initialHabits;
  final List<cat.Category> initialCategories;

  const HomePage({
    super.key,
    required this.initialHabits,
    required this.initialCategories,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = true;

  late List<utils.Habit> habits;
  late List<cat.Category> categories;

  final HabitStorage _habitStorage = HabitStorage();
  final CategoryStorage _categoryStorage = CategoryStorage();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🔹 Carrega hábitos e categorias do armazenamento local
  Future<void> _loadData() async {
    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // leve pausa estética

    final loadedHabits = await _habitStorage.loadHabits();
    final loadedCategories = await _categoryStorage.loadCategories();

    setState(() {
      habits = loadedHabits.isNotEmpty ? loadedHabits : widget.initialHabits;
      categories = loadedCategories.isNotEmpty
          ? loadedCategories
          : widget.initialCategories;
      _isLoading = false;
    });
  }

  Future<void> _saveHabits() async => _habitStorage.saveHabits(habits);
  Future<void> _saveCategories() async =>
      _categoryStorage.saveCategories(categories);

  void _updateHabits(List<utils.Habit> updatedHabits) {
    setState(() => habits = updatedHabits);
    _saveHabits();
  }

  void _updateCategories(List<cat.Category> updatedCategories) {
    setState(() => categories = updatedCategories);
    _saveCategories();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                child: Icon(
                  Icons.auto_graph_rounded,
                  size: 70,
                  color: Colors.indigo.shade400,
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Carregando seus hábitos...",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pages = [
      HabitsPage(
        habits: habits,
        categories: categories,
        onHabitsChanged: _updateHabits,
        onCategoriesChanged: _updateCategories,
      ),
      StatsPage(
        habits: habits,
        categories: categories,
        onCategoriesChanged: _updateCategories,
      ),
      HorizontalBarsPage(
        habits: habits,
        categories: categories,
        onCategoriesChanged: _updateCategories,
      ),
      HabitsMatrixPage(habits: habits),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Hábitos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pentagon_rounded), // ícone de pentágono
            label: 'Setores', // novo nome da aba
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Barras'),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Tabela',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/habit.dart';
import '../utils/category.dart';

class HorizontalBarsPage extends StatefulWidget {
  final List<Habit> habits;
  final List<Category> categories;
  final Function(List<Category>) onCategoriesChanged;

  const HorizontalBarsPage({
    super.key,
    required this.habits,
    required this.categories,
    required this.onCategoriesChanged,
  });

  @override
  _HorizontalBarsPageState createState() => _HorizontalBarsPageState();
}

class _HorizontalBarsPageState extends State<HorizontalBarsPage> {
  String selectedPeriod = 'Semana';

  final List<String> periods = [
    'Dia',
    'Semana',
    'Mês',
    '3 Meses',
    '6 Meses',
    '12 Meses',
    'Todo período',
  ];

  DateTime getStartDate(String period) {
    DateTime now = DateTime.now();
    switch (period) {
      case 'Dia':
        return DateTime(now.year, now.month, now.day);
      case 'Semana':
        return now.subtract(const Duration(days: 6));
      case 'Mês':
        return DateTime(now.year, now.month, 1);
      case '3 Meses':
        return DateTime(now.year, now.month - 2, 1);
      case '6 Meses':
        return DateTime(now.year, now.month - 5, 1);
      case '12 Meses':
        return DateTime(now.year, now.month - 11, 1);
      case 'Todo período':
        final allDates = widget.habits
            .expand((h) => h.points.keys)
            .toList()
            .cast<DateTime>();
        if (allDates.isEmpty) return now;
        allDates.sort();
        return allDates.first;
      default:
        return now;
    }
  }

  DateTime getEndDate(String period) => DateTime.now();

  double getTotalPointsForCategory(
    String categoryName,
    DateTime start,
    DateTime end,
  ) {
    return widget.habits
        .where((h) => h.category == categoryName)
        .map((h) => h.getPointsForPeriod(start, end).toDouble())
        .fold(0.0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    DateTime start = getStartDate(selectedPeriod);
    DateTime end = getEndDate(selectedPeriod);

    return Scaffold(
      appBar: AppBar(title: const Text('Barras Horizontais')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Período
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Período: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedPeriod,
                  elevation: 4,
                  underline: Container(height: 2, color: Colors.blueAccent),
                  items: periods
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPeriod = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Barras horizontais
            Column(
              children: widget.categories.map((category) {
                double points = getTotalPointsForCategory(
                  category.name,
                  start,
                  end,
                );
                int maxPoints =
                    category.maxPoints * (end.difference(start).inDays + 1);
                double percent = points / maxPoints;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${category.name} - ${points.toInt()} / $maxPoints pts',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      LinearProgressIndicator(
                        value: percent,
                        minHeight: 16,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

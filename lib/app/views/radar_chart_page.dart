import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/habit.dart';
import '../utils/category.dart';

class RadarChartPage extends StatefulWidget {
  final List<Habit> habits;
  final List<Category> categories;
  final Function(List<Category>) onCategoriesChanged;

  const RadarChartPage({
    super.key,
    required this.habits,
    required this.categories,
    required this.onCategoriesChanged,
  });

  @override
  _RadarChartPageState createState() => _RadarChartPageState();
}

class _RadarChartPageState extends State<RadarChartPage> {
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

  int getMaxPointsForPeriod(Category category, DateTime start, DateTime end) {
    int days = end.difference(start).inDays + 1;
    return category.maxPoints * days;
  }

  @override
  Widget build(BuildContext context) {
    DateTime start = getStartDate(selectedPeriod);
    DateTime end = getEndDate(selectedPeriod);

    final Map<String, double> pointsForRadar = {
      for (var category in widget.categories)
        category.name: getTotalPointsForCategory(category.name, start, end),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico Poligonal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showEditCategoriesDialog(context),
          ),
        ],
      ),
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
            Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: RadarChartPainter(
                  pointsForRadar,
                  widget.categories,
                  start,
                  end,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoriesDialog(BuildContext context) {
    List<Category> tempCategories = widget.categories
        .map((c) => Category(name: c.name, maxPoints: c.maxPoints))
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Categorias'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tempCategories.length,
            itemBuilder: (context, index) {
              String name = tempCategories[index].name;
              int maxPoints = tempCategories[index].maxPoints;

              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: TextEditingController(text: name),
                      decoration: const InputDecoration(labelText: 'Nome'),
                      onChanged: (value) => tempCategories[index].name = value,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: TextEditingController(
                        text: maxPoints.toString(),
                      ),
                      decoration: const InputDecoration(labelText: 'Max pts'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => tempCategories[index].maxPoints =
                          int.tryParse(value) ?? 100,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.onCategoriesChanged(tempCategories);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

// RadarChartPainter
class RadarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Category> categories;
  final DateTime start;
  final DateTime end;

  RadarChartPainter(this.data, this.categories, this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width, size.height) / 2 * 0.8;
    final double angleStep = 2 * pi / data.length;

    final List<Offset> points = [];
    int i = 0;

    data.forEach((key, value) {
      final category = categories.firstWhere(
        (c) => c.name == key,
        orElse: () => Category(name: key, maxPoints: 100),
      );
      int maxPoints = category.maxPoints * (end.difference(start).inDays + 1);
      double r = radius * (value / maxPoints);
      double x = center.dx + r * cos(i * angleStep - pi / 2);
      double y = center.dy + r * sin(i * angleStep - pi / 2);
      points.add(Offset(x, y));
      i++;
    });

    final Path path = Path()..addPolygon(points, true);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    i = 0;
    data.forEach((key, value) {
      double x = center.dx + (radius + 20) * cos(i * angleStep - pi / 2);
      double y = center.dy + (radius + 20) * sin(i * angleStep - pi / 2);
      final textPainter = TextPainter(
        text: TextSpan(
          text: key,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
      i++;
    });
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) => true;
}

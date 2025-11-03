import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/habit.dart';
import '../utils/category.dart';
import 'categories_page.dart';

class StatsPage extends StatelessWidget {
  final List<Habit> habits;
  final List<Category> categories;
  final Function(List<Category>) onCategoriesChanged;

  const StatsPage({
    super.key,
    required this.habits,
    required this.categories,
    required this.onCategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Mapeia cada categoria para os pontos acumulados
    final Map<String, double> habitPoints = {
      for (var cat in categories)
        cat.name: habits
            .where((h) => h.category == cat.name)
            .map((h) => h.weeklyPoints.toDouble())
            .fold(0.0, (a, b) => a + b),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico de Hábitos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Troquei a estrela pelo +
            tooltip: 'Editar Categorias',
            onPressed: () => _showCategoriesDialog(context),
          ),
        ],
      ),
      body: Center(
        child: CustomPaint(
          size: const Size(300, 300),
          painter: RadarChartPainter(habitPoints, categories),
        ),
      ),
    );
  }

  // Abre a página de edição de categorias
  void _showCategoriesDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesPage(
          categories: categories,
          onCategoriesChanged: onCategoriesChanged,
        ),
      ),
    );
  }
}

// Radar Chart Painter atualizado para usar os limites de cada categoria
class RadarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Category> categories;

  RadarChartPainter(this.data, this.categories);

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
      final cat = categories.firstWhere(
        (c) => c.name == key,
        orElse: () => Category(name: key, maxPoints: 100),
      );
      double percent = (cat.maxPoints > 0)
          ? (value / cat.maxPoints).clamp(0.0, 1.0)
          : 0.0;
      double r = radius * percent;
      double x = center.dx + r * cos(i * angleStep - pi / 2);
      double y = center.dy + r * sin(i * angleStep - pi / 2);
      points.add(Offset(x, y));
      i++;
    });

    final Path path = Path()..addPolygon(points, true);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Desenhar labels
    i = 0;
    data.forEach((key, value) {
      double x = center.dx + (radius + 20) * cos(i * angleStep - pi / 2);
      double y = center.dy + (radius + 20) * sin(i * angleStep - pi / 2);
      final TextPainter textPainter = TextPainter(
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

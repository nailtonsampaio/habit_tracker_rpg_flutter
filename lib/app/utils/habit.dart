// lib/app/utils/habit.dart
class Habit {
  String name;
  String category;
  String unitName;
  int unitPoints;

  // Armazena os pontos por data
  Map<DateTime, int> points = {};

  Habit({
    required this.name,
    required this.category,
    this.unitName = 'unidade',
    this.unitPoints = 1,
  });

  // Adiciona unidades em uma data específica
  void addUnits(int units, [DateTime? date]) {
    final d = DateTime(
      date?.year ?? DateTime.now().year,
      date?.month ?? DateTime.now().month,
      date?.day ?? DateTime.now().day,
    );
    points[d] = (points[d] ?? 0) + units * unitPoints;
  }

  // Retorna pontos de um dia específico
  int getPointsForDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return points[d] ?? 0;
  }

  // Retorna pontos acumulados entre duas datas (inclusive)
  int getPointsForPeriod(DateTime start, DateTime end) {
    int total = 0;
    for (var entry in points.entries) {
      final d = entry.key;
      if (!d.isBefore(start) && !d.isAfter(end)) {
        total += entry.value;
      }
    }
    return total;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'unitName': unitName,
    'unitPoints': unitPoints,
    'points': points.map(
      (k, v) => MapEntry('${k.year}-${k.month}-${k.day}', v),
    ), // salvar como string
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    final Map<DateTime, int> loadedPoints = {};
    if (json['points'] != null) {
      (json['points'] as Map<String, dynamic>).forEach((k, v) {
        final parts = k.split('-');
        final dt = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        loadedPoints[dt] = v;
      });
    }
    return Habit(
      name: json['name'],
      category: json['category'],
      unitName: json['unitName'] ?? 'unidade',
      unitPoints: json['unitPoints'] ?? 1,
    )..points = loadedPoints;
  }
}

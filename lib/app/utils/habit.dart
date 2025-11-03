class Habit {
  String name;
  String category; // Categoria associada
  String unitName;
  int unitPoints;
  int completedUnitsToday;
  int weeklyPoints;

  Habit({
    required this.name,
    required this.category,
    this.unitName = 'unidade',
    this.unitPoints = 1,
    this.completedUnitsToday = 0,
    this.weeklyPoints = 0,
  });

  void addUnits(int units) {
    completedUnitsToday += units;
    weeklyPoints += units * unitPoints;
  }

  void resetDaily() {
    completedUnitsToday = 0;
  }

  void resetWeekly() {
    weeklyPoints = 0;
    resetDaily();
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'unitName': unitName,
    'unitPoints': unitPoints,
    'completedUnitsToday': completedUnitsToday,
    'weeklyPoints': weeklyPoints,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    name: json['name'],
    category: json['category'],
    unitName: json['unitName'] ?? 'unidade',
    unitPoints: json['unitPoints'] ?? 1,
    completedUnitsToday: json['completedUnitsToday'] ?? 0,
    weeklyPoints: json['weeklyPoints'] ?? 0,
  );
}

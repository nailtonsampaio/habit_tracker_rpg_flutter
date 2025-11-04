// lib/app/views/habits_page.dart
import 'package:flutter/material.dart';
import '../utils/habit.dart';
import '../utils/category.dart';

class HabitsPage extends StatelessWidget {
  final List<Habit> habits;
  final List<Category> categories;
  final Function(List<Habit>) onHabitsChanged;
  final Function(List<Category>) onCategoriesChanged;

  const HabitsPage({
    super.key,
    required this.habits,
    required this.categories,
    required this.onHabitsChanged,
    required this.onCategoriesChanged,
  });

  Category? _findCategoryByName(String name) {
    try {
      return categories.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  void _showUnitsDialog(
    BuildContext context,
    Habit habit,
    List<Habit> allHabits,
  ) {
    int units = 1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Quantas unidades hoje',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleButton(Icons.remove, () {
                        setState(() {
                          if (units > 1) units--;
                        });
                      }),
                      const SizedBox(width: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              units.toString(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              habit.unitName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      _circleButton(Icons.add, () {
                        setState(() {
                          if (units < 10) units++;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cada unidade vale ${habit.unitPoints} ponto(s)',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    habit.addUnits(units);
                    onHabitsChanged([...allHabits]);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      elevation: 3,
      shape: const CircleBorder(),
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(icon, size: 28),
        ),
      ),
    );
  }

  // DIÁLOGO DE CRIAÇÃO DE HÁBITO COM CONTADOR DE PONTOS
  void _showAddHabitDialog(BuildContext context) {
    final nameCtl = TextEditingController();
    final unitCtl = TextEditingController(text: 'vezes');
    String selectedCategory = categories.isNotEmpty
        ? categories.first.name
        : 'Geral';
    int points = 1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Novo hábito',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Nome do hábito',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: [
                        ...categories.map(
                          (c) => DropdownMenuItem(
                            value: c.name,
                            child: Text(c.name),
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'Geral',
                          child: Text('Geral'),
                        ),
                      ],
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      onChanged: (v) =>
                          setState(() => selectedCategory = v ?? 'Geral'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: unitCtl,
                      decoration: const InputDecoration(
                        labelText: 'Nome da unidade',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pontos por unidade',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _circleButton(Icons.remove, () {
                          setState(() {
                            if (points > 1) points--;
                          });
                        }),
                        const SizedBox(width: 20),
                        Text(
                          '$points',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        _circleButton(Icons.add, () {
                          setState(() {
                            if (points < 10) points++;
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtl.text.trim().isEmpty) return;

                    final newHabit = Habit(
                      name: nameCtl.text.trim(),
                      category: selectedCategory,
                      unitName: unitCtl.text.trim(),
                      unitPoints: points,
                    );

                    final updated = [...habits, newHabit];
                    onHabitsChanged(updated);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditHabitDialog(BuildContext context, Habit habit) {
    final nameCtl = TextEditingController(text: habit.name);
    final unitCtl = TextEditingController(text: habit.unitName);
    int points = habit.unitPoints;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Editar hábito',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtl,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: unitCtl,
                    decoration: const InputDecoration(labelText: 'Unidade'),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pontos por unidade',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleButton(Icons.remove, () {
                        setState(() {
                          if (points > 1) points--;
                        });
                      }),
                      const SizedBox(width: 20),
                      Text(
                        '$points',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      _circleButton(Icons.add, () {
                        setState(() {
                          if (points < 10) points++;
                        });
                      }),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    habit.name = nameCtl.text;
                    habit.unitName = unitCtl.text;
                    habit.unitPoints = points;
                    onHabitsChanged([...habits]);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir hábito?'),
        content: Text('Deseja excluir "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final updated = List<Habit>.from(habits)..remove(habit);
              onHabitsChanged(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitRow(BuildContext context, int index) {
    final habit = habits[index];
    final today = DateTime.now();
    final todayPoints = habit.getPointsForDay(today);
    final todayUnits = habit.unitPoints != 0
        ? (todayPoints / habit.unitPoints).round()
        : todayPoints;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  habit.category,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  '$todayUnits',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text('(${todayPoints})', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.blue.shade600,
            elevation: 3,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _showUnitsDialog(context, habit, habits),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') _showEditHabitDialog(context, habit);
              if (v == 'delete') _showDeleteConfirm(context, habit);
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hábitos",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showAddHabitDialog(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 30),
            itemCount: habits.length,
            itemBuilder: (ctx, i) => _buildHabitRow(ctx, i),
          ),
        ),
      ],
    );
  }
}

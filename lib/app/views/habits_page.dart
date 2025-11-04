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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Hábitos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHabitDialog(context),
          ),
        ],
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text('Nenhum hábito adicionado. Clique no + para criar.'),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return ListTile(
                  title: Text('${habit.name} (${habit.unitName})'),
                  subtitle: Text(
                    '${habit.category} - ${habit.getPointsForDay(DateTime.now())} pts hoje',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Editar') {
                        _showEditHabitDialog(context, habit);
                      } else if (value == 'Adicionar unidades') {
                        _showAddUnitsDialog(context, habit);
                      } else if (value == 'Excluir') {
                        habits.remove(habit);
                        onHabitsChanged([...habits]);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'Editar', child: Text('Editar')),
                      PopupMenuItem(
                        value: 'Adicionar unidades',
                        child: Text('Adicionar unidades'),
                      ),
                      PopupMenuItem(value: 'Excluir', child: Text('Excluir')),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // === Adicionar Hábito ===
  void _showAddHabitDialog(BuildContext context) {
    String name = '';
    String category = categories.isNotEmpty ? categories.first.name : '';
    String unitName = '';
    int unitPoints = 1;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Novo Hábito'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (v) => name = v,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                onChanged: (v) => unitName = v,
                decoration: const InputDecoration(labelText: 'Unidade'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (unitPoints > 1) setState(() => unitPoints--);
                    },
                  ),
                  Text(
                    'Pontos por unidade: $unitPoints',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      if (unitPoints < 10) setState(() => unitPoints++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: category.isNotEmpty ? category : null,
                hint: const Text('Selecione a categoria'),
                items: categories
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.name, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    category = v ?? '';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (name.isEmpty || category.isEmpty) return;
                final newHabit = Habit(
                  name: name,
                  category: category,
                  unitName: unitName,
                  unitPoints: unitPoints,
                );
                onHabitsChanged([...habits, newHabit]);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // === Adicionar Unidades ===
  void _showAddUnitsDialog(BuildContext context, Habit habit) {
    int units = 1;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Adicionar unidades a ${habit.name}'),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (v) => units = int.tryParse(v) ?? 1,
          decoration: const InputDecoration(labelText: 'Quantidade'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Adicionar'),
            onPressed: () {
              habit.addUnits(units, DateTime.now());
              onHabitsChanged([...habits]);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // === Editar Hábito ===
  void _showEditHabitDialog(BuildContext context, Habit habit) {
    String name = habit.name;
    String category = habit.category;
    String unitName = habit.unitName;
    int unitPoints = habit.unitPoints;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Hábito'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (v) => name = v,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  hintText: habit.name,
                ),
              ),
              TextField(
                onChanged: (v) => unitName = v,
                decoration: InputDecoration(
                  labelText: 'Unidade',
                  hintText: habit.unitName,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (unitPoints > 1) setState(() => unitPoints--);
                    },
                  ),
                  Text(
                    'Pontos por unidade: $unitPoints',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      if (unitPoints < 10) setState(() => unitPoints++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: category,
                items: categories
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.name, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    category = v!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                habit.name = name;
                habit.category = category;
                habit.unitName = unitName;
                habit.unitPoints = unitPoints;
                onHabitsChanged([...habits]);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/habit.dart';

class HabitsMatrixPage extends StatelessWidget {
  final List<Habit> habits;

  const HabitsMatrixPage({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    // Número de dias exibidos (últimos 7)
    final int daysToShow = 7;
    final DateTime today = DateTime.now();
    final List<DateTime> days = List.generate(
      daysToShow,
      (i) => today.subtract(Duration(days: daysToShow - 1 - i)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo de Pontos por Hábito')),
      body: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            // Cabeçalho com as datas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.grey.shade300,
              child: Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'Hábito',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: days
                            .map(
                              (d) => Container(
                                width: 70,
                                alignment: Alignment.center,
                                child: Text(
                                  '${d.day}/${d.month}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Lista de hábitos (linhas da “planilha”)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: habits.map((habit) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Nome do hábito
                          Container(
                            width: 100,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              habit.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Pontos por dia
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: days.map((day) {
                                  final int points = habit.getPointsForDay(day);
                                  return Container(
                                    width: 70,
                                    height: 50,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: points > 0
                                          ? Colors.blue.shade50
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      '$points',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: points > 0
                                            ? Colors.blue.shade700
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

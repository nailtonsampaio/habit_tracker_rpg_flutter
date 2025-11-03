import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'habit.dart';

class HabitStorage {
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/habits.json');
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final file = await _localFile;
    final jsonData = habits.map((h) => h.toJson()).toList();
    await file.writeAsString(json.encode(jsonData));
  }

  Future<List<Habit>> loadHabits() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((h) => Habit.fromJson(h)).toList();
    } catch (_) {
      return [];
    }
  }
}

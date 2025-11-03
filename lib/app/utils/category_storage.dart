// lib/app/utils/category_storage.dart
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'category.dart';

class CategoryStorage {
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/categories.json');
  }

  Future<void> saveCategories(List<Category> categories) async {
    final file = await _localFile;
    final jsonData = categories.map((c) => c.toJson()).toList();
    await file.writeAsString(json.encode(jsonData));
  }

  Future<List<Category>> loadCategories() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((c) => Category.fromJson(c)).toList();
    } catch (_) {
      return [];
    }
  }
}

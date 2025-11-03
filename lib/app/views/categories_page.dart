import 'package:flutter/material.dart';
import '../utils/category.dart';

class CategoriesPage extends StatefulWidget {
  final List<Category> categories;
  final Function(List<Category>) onCategoriesChanged;

  const CategoriesPage({
    super.key,
    required this.categories,
    required this.onCategoriesChanged,
  });

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late List<Category> categories;

  @override
  void initState() {
    super.initState();
    categories = widget.categories
        .map((c) => Category(name: c.name, maxPoints: c.maxPoints))
        .toList();
  }

  void _addCategory() {
    String name = '';
    int maxPoints = 100;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nome'),
              onChanged: (v) => name = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Pontos máximos'),
              keyboardType: TextInputType.number,
              onChanged: (v) => maxPoints = int.tryParse(v) ?? 100,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty) {
                setState(
                  () => categories.add(
                    Category(name: name, maxPoints: maxPoints),
                  ),
                );
                widget.onCategoriesChanged(categories);
                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _editCategory(int index) {
    String name = categories[index].name;
    int maxPoints = categories[index].maxPoints;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nome'),
              controller: TextEditingController(text: name),
              onChanged: (v) => name = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Pontos máximos'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: maxPoints.toString()),
              onChanged: (v) => maxPoints = int.tryParse(v) ?? maxPoints,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                categories[index].name = name;
                categories[index].maxPoints = maxPoints;
              });
              widget.onCategoriesChanged(categories);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addCategory),
        ],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return ListTile(
            title: Text('${cat.name} (${cat.maxPoints} pts)'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editCategory(index),
            ),
          );
        },
      ),
    );
  }
}

class Category {
  String name;
  int maxPoints; // Limite definido pelo usuário

  Category({required this.name, required this.maxPoints});

  Map<String, dynamic> toJson() => {'name': name, 'maxPoints': maxPoints};

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(name: json['name'], maxPoints: json['maxPoints']);
}

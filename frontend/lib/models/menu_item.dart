class MenuItem {
  String id;
  String name;
  double price;
  String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'Unknown Item',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'Uncategorized',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
    };
  }
}

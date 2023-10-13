// models/product.dart

class Product {
  int? id; // Unique identifier for the product
  String name; // Name of the product
  String barcode; // Barcode of the product
  int count; // Quantity of the product in stock

  Product({
    this.id,
    required this.name,
    required this.barcode,
    required this.count,
  });

  // Convert a Product object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'count': count,
    };
  }

  // Create a Product object from a Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      barcode: map['barcode'],
      count: map['count'],
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    int? count,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      count: count ?? this.count,
    );
  }
}

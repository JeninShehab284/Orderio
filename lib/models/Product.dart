class Product {
  int? id;
  String name;
  double price;
  int quantity;
  int categoryId;
  String? image;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.categoryId,
    this.image,
  });

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json['id'] != null ? json['id'] as int : null,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
        categoryId: json['categoryId'] as int,
        image: json['image'] as String?,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'image': image,
    };
  }
}

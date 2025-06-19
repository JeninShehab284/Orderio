class CartItem {
  final int productId;
  final int customerId;
  final String name;
  final double price;
  int orderQuantity;
  final int quantity;
  final String? image;
  final int? categoryId;

  CartItem({
    required this.productId,
    required this.customerId,
    required this.name,
    required this.price,
    required this.orderQuantity,
    required this.quantity,
    this.image,
    this.categoryId,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      customerId: map['customerId'],
      name: map['name'],
      price:
          map['price'] is int ? (map['price'] as int).toDouble() : map['price'],
      orderQuantity: map['orderQuantity'] ?? 0,
      quantity: map['quantity'],
      image: map['image'],
      categoryId: map['categoryId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'customerId': customerId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'orderQuantity': orderQuantity,
      'image': image,
      'categoryId': categoryId,
    };
  }
}

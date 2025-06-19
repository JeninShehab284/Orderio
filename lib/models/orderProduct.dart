class OrderProduct {
  final int? orderProductId;
  final int? orderId;
  final int productId;
  final int orderQuantity;
  final double price;

  OrderProduct({
    this.orderProductId,
    this.orderId,
    required this.productId,
    required this.orderQuantity,
    required this.price,
  });

  factory OrderProduct.fromMap(Map<String, dynamic> map) {
    return OrderProduct(
      orderProductId: map['orderProductId'],
      orderId: map['orderId'],
      productId: map['productId'],
      orderQuantity: map['orderQuantity'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderProductId': orderProductId,
      'orderId': orderId,
      'productId': productId,
      'quantity': orderQuantity,
      'price': price,
    };
  }
}

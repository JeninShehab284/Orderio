class Order {
  int? id;
  int customerId;
  String orderDate;
  double totalAmount;
  String status;

  Order({
    this.id,
    required this.customerId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
  });

  factory Order.fromMap(Map<String, dynamic> json) => Order(
        id: json['id'],
        customerId: json['customerId'],
        orderDate: json['orderDate'],
        totalAmount: json['totalAmount'],
        status: json['status'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'orderDate': orderDate,
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}

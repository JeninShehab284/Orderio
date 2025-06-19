class Customer {
  int? id;
  String username;
  String phone;
  String address;
  String password;

  Customer({
    this.id,
    required this.username,
    required this.phone,
    required this.address,
    required this.password,
  });

  factory Customer.fromMap(Map<String, dynamic> json) => Customer(
        id: json['id'],
        username: json['username'],
        phone: json['phone'],
        address: json['address'],
        password: json['password'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'address': address,
      'password': password,
    };
  }
}

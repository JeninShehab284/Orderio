import 'package:flutter/material.dart';
import 'package:orderio/log_in_screen.dart';
import 'models/order.dart';
import 'package:orderio/db_helper.dart';
import 'shopping_screen.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  List<Order> orders = [];
  Map<int, List<Map<String, dynamic>>> orderDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final dbHelper = DBHelper();
    final currentUser = await dbHelper.getCurrentUser();

    if (currentUser == null || currentUser['id'] == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user founded.')),
      );
      return;
    }

    final customerId = currentUser['id'];
    final fetchedOrders = await dbHelper.getOrdersByCustomer(customerId);

    for (var order in fetchedOrders) {
      final details = await dbHelper.getOrderProducts(order.id!);
      print(details);
      orderDetails[order.id!] = details;
    }

    setState(() {
      orders = fetchedOrders;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => Shopping()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          title: Text('My Order'),
          centerTitle: true,
          backgroundColor: Color(0xFFCAB7AC),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
                if (value == 'myorder') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyOrder()),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'logout', child: Text('Logout')),
                PopupMenuItem(value: 'myorder', child: Text('My Order')),
              ],
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? Center(child: Text('No orders'))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final details = orderDetails[order.id!] ?? [];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.all(10),
                        color: Color(0xFFCAB7AC),
                        child: ExpansionTile(
                          title: Text(
                            '#${order.id.toString().padLeft(6, '0')}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Order Date: ${order.orderDate}'),
                              SizedBox(
                                height: 5,
                              ),
                              Text('Status: ${order.status}'),
                              SizedBox(
                                height: 5,
                              ),
                              Text('₪${order.totalAmount.toStringAsFixed(2)}'),
                            ],
                          ),
                          children: details.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(child: Text(item['name'])),
                                  Text('x${item['orderQuantity']}'),
                                  SizedBox(width: 10),
                                  Text('₪${item['price']}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

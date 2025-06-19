import 'package:flutter/material.dart';
import 'package:orderio/log_in_screen.dart';
import 'shopping_screen.dart';
import 'cart_screen.dart';
import 'db_helper.dart';
import 'my_order_screen.dart';
import 'models/orderProduct.dart';
import 'models/cartItem.dart';

class CheckOut extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;
  CheckOut({required this.cartItems, required this.totalPrice});

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  String username = '';
  String address = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final dbHelper = DBHelper();
    Map<String, dynamic>? currentUser = await dbHelper.getCurrentUser();

    if (currentUser != null) {
      setState(() {
        username = currentUser['username'] ?? '';
        address = currentUser['address'] ?? '';
        phone = currentUser['phone'] ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user founded')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text('Checkout'),
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
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
              PopupMenuItem(
                value: 'myorder',
                child: Text('My Order'),
              )
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 40.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shipping',
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Text(
                        'Name: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        '$username',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 14.0),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Address: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        '$address',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 14.0),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 3.0,
                  ),
                  Row(
                    children: [
                      Text(
                        'Phone: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        '$phone',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summery',
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    itemCount: widget.cartItems.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final product = widget.cartItems[index];
                      return ListTile(
                        leading: Image.asset(
                          product.image ?? 'images/default.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('₪${product.price}'),
                            //Text('${product.quantity}'),
                          ],
                        ),
                        trailing: Text('${product.orderQuantity}'),
                      );
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    'Total price:  ₪${widget.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Color(0xFFCAB7AC),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Shopping()));
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CartScreen()));
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_sharp,
              ),
              label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
        ],
      ),
      bottomSheet: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFCAB7AC),
          ),
          onPressed: () async {
            print("Submit Order button pressed");
            final dbHelper = DBHelper();
            final currentUser = await dbHelper.getCurrentUser();
            if (currentUser == null || currentUser['id'] == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('You are not logged in.'),
              ));
              return;
            }
            final customerId = currentUser['id'];
            final cartItems = widget.cartItems;
            if (cartItems.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('The Cart is empty!')),
              );
              return;
            }

            //final totalAmount = await dbHelper.calculateCartTotal(customerId);
            double totalAmount = 0.0;
            for (var p in cartItems) {
              totalAmount += (p.price * p.orderQuantity);
            }

            print("Cart items: ");
            for (var p in cartItems) {
              print(
                  "ID: ${p.name},totalAmount:$totalAmount, Quantity: ${p.orderQuantity}, Price: ${p.price}");
            }

            List<OrderProduct> orderProducts = cartItems
                .map((p) => OrderProduct(
                      productId: p.productId!,
                      orderQuantity: p.quantity,
                      price: p.price,
                    ))
                .toList();
            final cartItemsMap = cartItems.map((p) => p.toMap()).toList();
            final orderId = await dbHelper.insertOrder(
                customerId, totalAmount, cartItemsMap);

            if (orderId > 0) {
              await dbHelper.insertOrderProducts(orderId, orderProducts);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('The order was sent successfully.')),
              );

              await dbHelper.clearCart(customerId);
              cartItems.clear();
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to register the order!')),
              );
            }
          },
          child: Text(
            'Submit Order',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:orderio/checkout_screen.dart';
import 'package:orderio/log_in_screen.dart';
import 'package:orderio/models/cartItem.dart';
import 'shopping_screen.dart';
import 'db_helper.dart';
import 'my_order_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  double price = 0.0;

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }

  double getTotalPrice() {
    double total = 0.0;
    for (var product in cartItems) {
      total += product.price * product.orderQuantity;
    }
    return total;
  }

  Future<void> loadCartItems() async {
    final dbHelper = DBHelper();
    final int userId = await dbHelper.getCurrentUserId();
    final items = await dbHelper.getCartItems(userId);
    for (var item in items) {
      print('${item.name} - ${item.orderQuantity}');
    }
    setState(() {
      cartItems = items;
      price = getTotalPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
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
      body: cartItems.isEmpty
          ? Center(
              child: Text('EMPTY CART'),
            )
          : ListView.builder(
              padding: EdgeInsets.only(bottom: 80),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: Image.asset(
                    item.image ?? 'images/default.jpg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₪${item.price}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () async {
                                if (item.orderQuantity > 1) {
                                  final dbHelper = DBHelper();
                                  int newQuantity = item.orderQuantity - 1;
                                  await dbHelper.updateCartQuantity(
                                      item.productId,
                                      item.customerId,
                                      newQuantity);
                                  setState(() {
                                    item.orderQuantity = newQuantity;
                                    price = getTotalPrice();
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.remove,
                                color: Colors.black,
                              )),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              item.orderQuantity.toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                final dbHelper = DBHelper();
                                await dbHelper.updateCartQuantity(
                                    item.productId,
                                    item.customerId,
                                    item.orderQuantity + 1);
                                await loadCartItems();
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.black,
                              )),
                        ],
                      )
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () async {
                      final dbHelper = DBHelper();
                      final productIdToDelete = cartItems[index].productId;
                      final customerId = await dbHelper.getCurrentUserId();

                      if (productIdToDelete != null) {
                        await dbHelper.deleteFromCart(
                            productIdToDelete, customerId);
                      }
                      setState(() {
                        cartItems.removeAt(index);
                        price = getTotalPrice();
                      });
                    },
                  ),
                );
              },
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
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black, blurRadius: 4, offset: Offset(0, -2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total : ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₪$price',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCAB7AC),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckOut(
                              cartItems: cartItems,
                              totalPrice: getTotalPrice(),
                            )),
                  );

                  if (result == true) {
                    loadCartItems();
                    setState(() {});
                  }
                },
                child: Text('CheckOut'))
          ],
        ),
      ),
    );
  }
}

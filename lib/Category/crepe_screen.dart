import 'package:flutter/material.dart';
import 'package:orderio/cart_screen.dart';
import 'package:orderio/log_in_screen.dart';
import 'package:orderio/shopping_screen.dart';
import 'package:orderio/models/Product.dart';
import 'package:orderio/cart_data.dart';
import 'package:orderio/loading.dart';
import 'package:orderio/db_helper.dart';
import 'package:orderio/models/Category.dart';
import 'package:orderio/my_order_screen.dart';

class CrepeScreen extends StatefulWidget {
  const CrepeScreen({super.key});

  @override
  State<CrepeScreen> createState() => _CrepeScreenState();
}

class _CrepeScreenState extends State<CrepeScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Category? crepeCategory;

  Future<void> loadProducts() async {
    List<Category> categories = await dbHelper.getCategories();
    crepeCategory = categories.firstWhere((cat) => cat.name == 'Crepe');
    List<Product> fetchedProducts =
        await dbHelper.getProductsByCategory(crepeCategory!.id!);
    print('Products found: ${fetchedProducts.length}');
    setState(() {
      products = fetchedProducts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crepe Hijabs'),
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
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
        children: products.map((product) {
          return productCard(product);
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
    );
  }

  Widget productCard(Product product) {
    String imagePath = product.image ?? 'images/default.jpg';
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.asset(
                  imagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              product.name,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  '₪${product.price}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                Spacer(),
                IconButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const LoadingScreen(),
                      );

                      await Future.delayed(Duration(seconds: 1));

                      Navigator.pop(context);

                      final dbHelper = DBHelper();
                      int customerId = await dbHelper.getCurrentUserId();
                      if (product.id != null) {
                        Product productWithImage = Product(
                          id: product.id,
                          name: product.name,
                          price: product.price,
                          quantity: product.quantity,
                          categoryId: product.categoryId,
                          image: imagePath,
                        );

                        await dbHelper.insertToCart(
                            productWithImage, customerId);
                        setState(() {
                          cartItems.add(productWithImage);
                        });
                      } else {
                        print('Error: product.id is null');
                      }
                    },
                    icon: Icon(Icons.shopping_cart))
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:orderio/log_in_screen.dart';
import 'main.dart';
import 'cart_screen.dart';
import 'my_order_screen.dart';
import 'Category/chiffon_screen.dart';
import 'Category/cotton_screen.dart';
import 'Category/crepe_screen.dart';
import 'Category/linen_screen.dart';
import 'Category/jersey_screen.dart';
import 'Category/modal_screen.dart';
import 'Category/silk_screen.dart';
import 'Category/crimps_screen.dart';
import 'models/Category.dart';
import 'db_helper.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  late Future<List<Category>> _categoriesFuture;
  @override
  void initState() {
    super.initState();
    _categoriesFuture = DBHelper().getCategories();
  }

  Widget _getTargetPage(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'chiffon':
        return ChiffonScreen();
      case 'cotton':
        return CottonScreen();
      case 'silk':
        return SilkScreen();
      case 'crepe':
        return CrepeScreen();
      case 'jersey':
        return JerseyScreen();
      case 'linen':
        return LinenScreen();
      case 'modal':
        return ModalScreen();
      case 'crimps':
        return CrimpsScreen();
      default:
        return Scaffold(
          appBar: AppBar(title: Text('Unknown Category')),
          body: Center(child: Text('No screen found for $categoryName')),
        );
    }
  }

  String _getImagePath(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'chiffon':
        return 'images/chif/chiffon.jpg';
      case 'cotton':
        return 'images/cot/cotton.jpg';
      case 'silk':
        return 'images/silkkk/silk.jpg';
      case 'crepe':
        return 'images/crepee/crepe.jpg';
      case 'jersey':
        return 'images/jerseyy/jersey.jpg';
      case 'linen':
        return 'images/linenn/linen.jpg';
      case 'modal':
        return 'images/modall/modal.jpg';
      case 'crimps':
        return 'images/crimpss/crimps.jpg';
      default:
        return 'images/default.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping'),
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
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading categories'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No categories found'));
          } else {
            final categories = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryButton(
                  categoryName: category.name,
                  targetPage: _getTargetPage(category.name),
                  imagePath: _getImagePath(category.name),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Color(0xFFCAB7AC),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Shopping()));
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CartScreen()));
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String categoryName;
  final Widget targetPage;
  final String imagePath;

  const CategoryButton({
    super.key,
    required this.categoryName,
    required this.targetPage,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFCAB7AC),
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => targetPage));
        },
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                imagePath,
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Text(
                categoryName,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

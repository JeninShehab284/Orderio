import 'package:orderio/models/cartItem.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/Category.dart';
import 'models/Product.dart';
import 'models/orderProduct.dart';
import 'models/order.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'orderio.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        address TEXT,
        phone TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        quantity INTEGER,
        categoryId INTEGER,
        image TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER,
        orderDate TEXT,
        totalAmount REAL,
        status TEXT,
        FOREIGN KEY (customerId) REFERENCES customers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE order_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER,
        productId INTEGER,
        orderQuantity INTEGER,
        price REAL,
        FOREIGN KEY (orderId) REFERENCES orders(id),
        FOREIGN KEY (productId) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE cart (
  productId INTEGER,
  customerId INTEGER,
  name TEXT,
  price REAL,
  orderQuantity INTEGER,
  quantity INTEGER,
  image TEXT,
  categoryId INTEGER,
  PRIMARY KEY (productId, customerId),
  FOREIGN KEY (customerId) REFERENCES customers(id)
)
    ''');
    await db.execute('''
    CREATE TABLE current_user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER
)
    ''');

    await db.execute('''
    CREATE TABLE app_settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT UNIQUE,
  value TEXT
)
    ''');

    await _insertInitialCategories(db);
    await _insertInitialProducts(db);
  }

  Future<void> _insertInitialCategories(Database db) async {
    List<Category> categories = [
      Category(name: 'Chiffon'),
      Category(name: 'Cotton'),
      Category(name: 'Silk'),
      Category(name: 'Crepe'),
      Category(name: 'Jersey'),
      Category(name: 'Linen'),
      Category(name: 'Modal'),
      Category(name: 'Crimps'),
    ];

    for (var category in categories) {
      await db.insert('categories', category.toMap());
    }
  }

  Future<Map<String, int>> _getCategoriesMap(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return {for (var row in maps) row['name'] as String: row['id'] as int};
  }

  Future<void> _insertInitialProducts(Database db) async {
    Map<String, int> categoriesMap = await _getCategoriesMap(db);
    List<Product> products = [
      Product(
          name: 'White Chiffon',
          price: 25,
          quantity: 10,
          categoryId: categoriesMap['Chiffon']!,
          image: 'images/chif/wchiffon.jpg'),
      Product(
          name: 'Brown Chiffon',
          price: 25,
          quantity: 10,
          categoryId: categoriesMap['Chiffon']!,
          image: 'images/chif/bchiffon.jpg'),
      Product(
          name: 'Pink Chiffon',
          price: 25,
          quantity: 10,
          categoryId: categoriesMap['Chiffon']!,
          image: 'images/chif/pchiffon.jpg'),
      Product(
          name: 'Grey Chiffon',
          price: 25,
          quantity: 10,
          categoryId: categoriesMap['Chiffon']!,
          image: 'images/chif/gchiffon.jpg'),
      Product(
          name: 'Beige Cotton',
          price: 20,
          quantity: 10,
          categoryId: categoriesMap['Cotton']!,
          image: 'images/cot/bcotton.jpg'),
      Product(
          name: 'Black Cotton',
          price: 20,
          quantity: 10,
          categoryId: categoriesMap['Cotton']!,
          image: 'images/cot/blacotton.jpg'),
      Product(
          name: 'Blue Cotton',
          price: 20,
          quantity: 10,
          categoryId: categoriesMap['Cotton']!,
          image: 'images/cot/blucotton.jpg'),
      Product(
          name: 'Brown Cotton',
          price: 20,
          quantity: 10,
          categoryId: categoriesMap['Cotton']!,
          image: 'images/cot/brcotton.jpg'),
      Product(
          name: 'Black Silk',
          price: 35,
          quantity: 10,
          categoryId: categoriesMap['Silk']!,
          image: 'images/silkkk/blacksilk.webp'),
      Product(
          name: 'Earthy Silk',
          price: 35,
          quantity: 10,
          categoryId: categoriesMap['Silk']!,
          image: 'images/silkkk/earthysilk.webp'),
      Product(
          name: 'Pearl Silk',
          price: 35,
          quantity: 10,
          categoryId: categoriesMap['Silk']!,
          image: 'images/silkkk/pearlsilk.webp'),
      Product(
          name: 'Sky Silk',
          price: 35,
          quantity: 10,
          categoryId: categoriesMap['Silk']!,
          image: 'images/silkkk/skysilk.webp'),
      Product(
          name: 'Brown Crepe',
          price: 15,
          quantity: 10,
          categoryId: categoriesMap['Crepe']!,
          image: 'images/crepee/browncrepe.webp'),
      Product(
          name: 'Green Crepe',
          price: 15,
          quantity: 10,
          categoryId: categoriesMap['Crepe']!,
          image: 'images/crepee/greencrepe.webp'),
      Product(
          name: 'Purple Crepe',
          price: 15,
          quantity: 10,
          categoryId: categoriesMap['Crepe']!,
          image: 'images/crepee/Purplecrep.webp'),
      Product(
          name: 'Red Crepe',
          price: 15,
          quantity: 10,
          categoryId: categoriesMap['Crepe']!,
          image: 'images/crepee/redcrepe.webp'),
    ];

    for (var product in products) {
      int id = await db.insert('products', product.toMap());
      product.id = id;
    }
  }

  Future<int> insertProduct(Product product) async {
    final dbClient = await db;
    return await dbClient.insert('products', product.toMap());
  }
  //.........................................................

  Future<int> insertCustomer(Map<String, dynamic> customerMap) async {
    final dbClient = await db;
    return await dbClient.insert('customers', customerMap);
  }

  Future<void> setSetting(String key, String value) async {
    final dbClient = await db;
    await dbClient.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future<void> setCurrentUser(int customerId) async {
    final dbClient = await db;
    await dbClient.delete('current_user');
    await dbClient.insert('current_user', {'customer_id': customerId});
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.rawQuery('''
    SELECT c.* FROM customers c
    INNER JOIN current_user cu ON cu.customer_id = c.id
    LIMIT 1
  ''');
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Category>> getCategories() async {
    final dbClient = await db;
    final result = await dbClient.query('categories');
    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final dbClient = await db;
    final result = await dbClient
        .query('products', where: 'categoryId = ?', whereArgs: [categoryId]);
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> getCurrentUserId() async {
    final dbClient = await db;
    final result = await dbClient.query('current_user', limit: 1);
    if (result.isNotEmpty) {
      return result.first['customer_id'] as int;
    } else {
      throw Exception('No current user found');
    }
  }

  Future<List<CartItem>> getCartItems(int customerId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.rawQuery(
      '''
    SELECT 
      c.productId AS productId,
      c.customerId AS customerId,
      p.name AS name,
      p.price AS price,
      c.orderQuantity AS orderQuantity,
      c.quantity AS quantity,
      p.image AS image,
      p.categoryId AS categoryId
    FROM cart c
    JOIN products p ON c.productId = p.id
    WHERE c.customerId = ?
    ''',
      [customerId],
    );

    return result.map((item) => CartItem.fromMap(item)).toList();
  }

  Future<int> updateCartQuantity(
      int productId, int customerId, int newQuantity) async {
    final dbClient = await db;
    return await dbClient.update(
      'cart',
      {'orderQuantity': newQuantity},
      where: 'productId = ? AND customerId = ?',
      whereArgs: [productId, customerId],
    );
  }

  Future<void> insertToCart(Product product, int customerId) async {
    final dbClient = await db;

    final dataToInsert = {
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'orderQuantity': 1,
      'quantity': product.quantity,
      'image': product.image,
      'categoryId': product.categoryId,
      'customerId': customerId,
    };

    print('Data to insert in cart: $dataToInsert');

    final existing = await dbClient.query(
      'cart',
      where: 'productId = ? AND customerId= ?',
      whereArgs: [product.id, customerId],
    );

    if (existing.isNotEmpty) {
      final currentQuantity = existing.first['orderQuantity'] as int;
      await dbClient.update(
        'cart',
        {'orderQuantity': currentQuantity + 1},
        where: 'productId = ? AND customerId = ?',
        whereArgs: [product.id, customerId],
      );
    } else {
      await dbClient.insert(
        'cart',
        {
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'orderQuantity': 1,
          'quantity': product.quantity,
          'image': product.image,
          'categoryId': product.categoryId,
          'customerId': customerId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    final all = await dbClient.query('cart');
    for (var item in all) {
      print(item);
    }
  }

  Future<void> deleteFromCart(int productId, int customerId) async {
    final dbClient = await db;
    await dbClient.delete(
      'cart',
      where: 'productId = ? AND customerId = ?',
      whereArgs: [productId, customerId],
    );
  }

  //....................................................

  Future<List<Map<String, dynamic>>> getCustomerByUsernameAndPassword(
      String username, String password) async {
    final dbClient = await db;
    return await dbClient.query(
      'customers',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
  }

  Future<int> insertOrder(int customerId, double totalAmount,
      List<Map<String, dynamic>> cartItems) async {
    final dbClient = await db;

    final orderId = await dbClient.insert('orders', {
      'customerId': customerId,
      'orderDate': DateTime.now().toIso8601String(),
      'totalAmount': totalAmount,
      'status': 'Pending',
    });

    for (var item in cartItems) {
      await dbClient.insert('order_products', {
        'orderId': orderId,
        'productId': item['productId'],
        'orderQuantity': item['orderQuantity'],
        'price': item['price'],
      });

      await dbClient.rawUpdate('''
      UPDATE products 
      SET quantity = quantity - ? 
      WHERE id = ?
    ''', [item['orderQuantity'], item['productId']]);
    }

    await clearCart(customerId);
    return orderId;
  }

  Future<void> insertOrderProduct(OrderProduct orderProduct) async {
    final dbClient = await db;
    await dbClient.insert('order_products', orderProduct.toMap());
  }

  Future<void> insertOrderProducts(
      int orderId, List<OrderProduct> products) async {
    final dbClient = await db;
    for (final product in products) {
      await dbClient.insert('order_products', {
        'orderId': orderId,
        'productId': product.productId,
        'orderQuantity': product.orderQuantity,
        'price': product.price,
      });
    }
  }

  Future<List<Product>> getAllProducts() async {
    final dbClient = await db;
    final result = await dbClient.query('products');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final dbClient = await db;
    return await dbClient.query('customers');
  }

  Future<void> clearCart(int customerId) async {
    final dbClient = await db;
    await dbClient
        .delete('cart', where: 'customerId = ?', whereArgs: [customerId]);
  }

  Future<List<Order>> getOrdersByCustomer(int customerId) async {
    final dbClient = await db;
    final result = await dbClient
        .query('orders', where: 'customerId = ?', whereArgs: [customerId]);
    return result.map((e) => Order.fromMap(e)).toList();
  }

  Future<List<OrderProduct>> getOrderProductsByOrderId(int orderId) async {
    final dbClient = await db;
    final result = await dbClient
        .query('order_products', where: 'orderId = ?', whereArgs: [orderId]);
    return result.map((e) => OrderProduct.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getOrderProducts(int orderId) async {
    final dbClient = await db;
    return await dbClient.rawQuery('''
    SELECT 
      p.name,
      op.orderQuantity,
      op.price
    FROM order_products op
    JOIN products p ON op.productId = p.id
    WHERE op.orderId = ?
    AND op.rowid = (
      SELECT MIN(rowid)
      FROM order_products
      WHERE orderId = ? AND productId = op.productId
    )
  ''', [orderId, orderId]);
  }
}

import 'package:shop_helper/data/models/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'shop_helper.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        name TEXT,
        barcode TEXT,
        count INTEGER
      )
    ''');
  }

  Future<int> insertProduct(Product product) async {
    final dbClient = await db;
    return await dbClient.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final dbClient = await db;
    final productsMapList = await dbClient.query('products');
    return productsMapList.map((productMap) => Product.fromMap(productMap)).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final dbClient = await db;
    final productMapList = await dbClient.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (productMapList.isEmpty) {
      return null;
    } else {
      return Product.fromMap(productMapList.first);
    }
  }

  Future<int> increaseProductCount(String barcode, int amount) async {
    final dbClient = await db;
    final product = await getProductByBarcode(barcode);
    if (product != null) {
      final updatedCount = product.count + amount;
      await dbClient.update(
        'products',
        {'count': updatedCount},
        where: 'barcode = ?',
        whereArgs: [barcode],
      );
      return updatedCount;
    }
    return 0; // Product not found
  }

  Future<int> decreaseProductCount(String barcode, int amount) async {
    final dbClient = await db;
    final product = await getProductByBarcode(barcode);
    if (product != null) {
      final updatedCount = product.count - amount;
      if (updatedCount > 0) {
        await dbClient.update(
          'products',
          {'count': updatedCount},
          where: 'barcode = ?',
          whereArgs: [barcode],
        );
        return updatedCount;
      } else {
        await dbClient.delete('products', where: 'barcode =?', whereArgs: [barcode]);
      }
    }
    return 0; // Product not found or count cannot be decreased
  }

  Future<void> clearTable() async {
    final dbClient = await db;
    await dbClient.delete('products');
  }
}

import 'package:flutter/material.dart';
import 'package:shop_helper/data/models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final List<Product> products;

  const ProductDetailScreen(this.products, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index].name),
            subtitle: Text('Barcode: ${products[index].barcode} Count: ${products[index].count}'),
          );
        },
      ),
    );
  }
}

import 'package:shop_helper/data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<Product> {
  ProductCubit() : super(Product(name: '', barcode: '', count: 0));

  updateCount(int count) => emit(state.copyWith(count: count));

  updateName(String name) => emit(state.copyWith(name: name));

  updateBarcode(String barcode) => emit(state.copyWith(barcode: barcode));

  updateData(Product newProduct) => emit(newProduct);

  void clearProductData() {
    emit(Product(name: '', barcode: '', count: 0));
  }
}

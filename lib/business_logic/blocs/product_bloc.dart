import 'dart:async';
import 'package:shop_helper/data/models/product_model.dart';
import 'package:shop_helper/data/service/local/database_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ProductEvent {}

class ScanBarcodeEvent extends ProductEvent {
  final String barcode;

  ScanBarcodeEvent(this.barcode);
}

class ClearTableEvent extends ProductEvent {}

class GetProductsEvent extends ProductEvent {
  // You can add any necessary parameters or data needed for this event
}

class SaleProductEvent extends ProductEvent {
  final String barcode;

  SaleProductEvent(this.barcode);
}

class AddProductEvent extends ProductEvent {
  final Product product;

  AddProductEvent(this.product);
}

class UpdateProductEvent extends ProductEvent {
  final Product product;

  UpdateProductEvent(this.product);
}

// States
abstract class ProductState {}

class ProductInitialState extends ProductState {}

class ProductLoadingState extends ProductState {}

class ProductLoadedState extends ProductState {
  final List<Product> products;

  ProductLoadedState(this.products);
}

class ProductErrorState extends ProductState {
  final String error;

  ProductErrorState(this.error);
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  ProductBloc() : super(ProductInitialState()) {
    on<GetProductsEvent>(_getProducts);
    on<ScanBarcodeEvent>(_scanBarcode);
    on<SaleProductEvent>(_saleProduct);
    on<AddProductEvent>(_addProduct);
    on<UpdateProductEvent>(_updateProduct);
    on<ClearTableEvent>(_clearTable);
  }

  Future<void> _getProducts(GetProductsEvent event, Emitter emit) async {
    emit(ProductLoadingState());
    try {
      final products = await dbHelper.getAllProducts();
      emit(ProductLoadedState(products));
    } catch (e) {
      emit(ProductErrorState("Error: $e"));
    }
  }

  Future<void> _clearTable(ClearTableEvent event, Emitter emit) async {
    emit(ProductLoadingState());
    try {
      await dbHelper.clearTable(); // Call the method in your DatabaseHelper to clear the table
      emit(ProductLoadedState([])); // Notify that the table is cleared
    } catch (e) {
      emit(ProductErrorState("Error: $e"));
    }
  }

  Future<void> _scanBarcode(ScanBarcodeEvent event, Emitter emit) async {
    emit(ProductLoadingState());
    try {
      final product = await dbHelper.getProductByBarcode(event.barcode);
      if (product != null) {
        await _decreaseProductCount(event.barcode);
      } else {
        emit(ProductErrorState("Product not found"));
      }
    } catch (e) {
      emit(ProductErrorState("Error: $e"));
    }
  }

  Future<void> _saleProduct(SaleProductEvent event, Emitter emit) async {
    emit(ProductLoadingState());
    try {
      final product = await dbHelper.getProductByBarcode(event.barcode);
      if (product != null) {
        await _decreaseProductCount(event.barcode);
      } else {
        emit(ProductErrorState("Product not found"));
      }
    } catch (e) {
      emit(ProductErrorState("Error: $e"));
    }
  }

  Future<void> _addProduct(AddProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      final product = await dbHelper.getProductByBarcode(event.product.barcode);
      if (product != null) {
        await _increaseProductCount(event.product.barcode);
      } else {
        dbHelper.insertProduct(event.product);
      }
      await _emitLoadedState(emit);
    } catch (e) {
      emit(ProductErrorState("Error: $e"));
    }
  }

  Future<void> _updateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      final product = await dbHelper.getProductByBarcode(event.product.barcode);
      if (product != null) {
        await _increaseProductCount(event.product.barcode, event.product.count);
      } else {
        dbHelper.insertProduct(event.product);
      }
      await _emitLoadedState(emit);
    } catch (e) {
      emit(ProductErrorState("Error: $e"));
    }
  }

  Future<void> _decreaseProductCount(String barcode) async {
    await dbHelper.decreaseProductCount(barcode, 1);
    await _emitLoadedState();
  }

  Future<void> _increaseProductCount(String barcode, [int amount = 1]) async {
    await dbHelper.increaseProductCount(barcode, amount);
    await _emitLoadedState();
  }

  Future<void> _emitLoadedState([Emitter<ProductState>? emit]) async {
    final products = await dbHelper.getAllProducts();
    if (emit != null) {
      emit(ProductLoadedState(products));
    } else {
      add(GetProductsEvent()); // Trigger a GetProductsEvent to reload the state
    }
  }
}

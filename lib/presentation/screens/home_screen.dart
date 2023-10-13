import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_helper/business_logic/blocs/product_bloc.dart';
import 'package:shop_helper/business_logic/cubits/product_cubit.dart';
import 'package:shop_helper/presentation/screens/get_barcode_screen.dart';
import 'package:shop_helper/presentation/screens/sale_product_screen.dart';
import 'package:shop_helper/presentation/utils/mixins/divider_mixin.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ProductBloc>().add(GetProductsEvent());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Market'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                context.read<ProductBloc>().add(ClearTableEvent());
              },
              icon: Icon(FontAwesomeIcons.trashCan))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoadedState) {
                  // Display the list of products when the data is available
                  return state.products.isEmpty
                      ? Center(
                          child: Text(
                          'Cart is Empty',
                          style: context.titleLarge,
                        ))
                      : ListView.builder(
                          itemCount: state.products.length,
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            return ListTile(
                              title: Text(product.name),
                              subtitle:
                                  Text('Barcode: ${product.barcode}\nCount: ${product.count}'),
                              // You can add more details or actions here as needed.
                            );
                          },
                        );
                } else if (state is ProductErrorState) {
                  return Center(
                      child: Text(
                    'Error loading products: ${state.error}',
                    style: context.titleLarge,
                  ));
                } else {
                  // Display a loading indicator or an error message when the data is not available
                  return const Center(
                      child: CircularProgressIndicator()); // Example of a loading indicator
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlobalButton(
                  label: 'Sale Product',
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const SaleProductScreen()));
                  },
                  iconData: FontAwesomeIcons.cartShopping,
                ),
                GlobalButton(
                  label: 'Add Product',
                  onPressed: () {
                    context.read<ProductCubit>().clearProductData();
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const GetBarcodeScreen()));
                  },
                  iconData: FontAwesomeIcons.cartPlus,
                ),
              ].divide(const SizedBox(width: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

class GlobalButton extends StatelessWidget {
  const GlobalButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.iconData,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: FaIcon(iconData),
          label: Text(label),
        ),
      ),
    );
  }
}

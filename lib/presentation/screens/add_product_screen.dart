import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_helper/business_logic/blocs/product_bloc.dart';
import 'package:shop_helper/business_logic/cubits/product_cubit.dart';
import 'package:shop_helper/data/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final Product? existingProduct;

  AddProductScreen({this.existingProduct, Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final productCubit = context.read<ProductCubit>();
    return BlocProvider(
      create: (context) => ProductBloc(), // Provide ProductBloc
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Product'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Product Name:'),
                      TextFormField(
                        initialValue:
                            productCubit.state.name.isNotEmpty ? productCubit.state.name : null,
                        enabled: productCubit.state.name.isEmpty,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<ProductCubit>().updateName(value);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Product Count:'),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Product count is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<ProductCubit>().updateCount(int.parse(value));
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Product Barcode:'),
                      TextFormField(
                        decoration: InputDecoration(
                            suffix: Icon(
                          FontAwesomeIcons.barcode,
                          color: context.theme.disabledColor,
                        )),
                        enabled: false,
                        initialValue: context.read<ProductCubit>().state.barcode,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final product = context.read<ProductCubit>().state;
                            if (widget.existingProduct != null) {
                              context
                                  .read<ProductBloc>()
                                  .add(UpdateProductEvent(productCubit.state));
                            } else {
                              context.read<ProductBloc>().add(AddProductEvent(product));
                            }
                            context.read<ProductBloc>().add(GetProductsEvent());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Product updated/added')),
                            );

                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Update/Add Product'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

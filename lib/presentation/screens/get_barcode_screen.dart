import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shop_helper/business_logic/cubits/product_cubit.dart';
import 'package:shop_helper/data/service/local/database_helper.dart';
import 'package:shop_helper/presentation/screens/add_product_screen.dart';

class GetBarcodeScreen extends StatefulWidget {
  const GetBarcodeScreen({super.key});

  @override
  _GetBarcodeScreenState createState() => _GetBarcodeScreenState();
}

class _GetBarcodeScreenState extends State<GetBarcodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final dbHelper = DatabaseHelper();

  // Variable to track the flashlight status
  bool isFlashOn = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Function to toggle the flashlight
  void toggleFlashlight() {
    if (controller != null) {
      if (isFlashOn) {
        controller!.toggleFlash();
        setState(() {
          isFlashOn = false;
        });
      } else {
        controller!.toggleFlash();
        setState(() {
          isFlashOn = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          FloatingActionButton(onPressed: toggleFlashlight, child: const Icon(Icons.flash_on)),
      appBar: AppBar(
        title: const Text('Get Barcode'),
      ),
      body: Stack(
        children: [
          QRView(
            overlay: QrScannerOverlayShape(),
            key: qrKey,
            onQRViewCreated: (QRViewController controller) {
              this.controller = controller;
              controller.scannedDataStream.listen((scanData) async {
                if (scanData.code != null) {
                  final productCubit = context.read<ProductCubit>();
                  final barcode = scanData.code!;
                  productCubit.updateBarcode(barcode);
                  await controller.stopCamera();

                  // Check if the product exists in the database
                  final existingProduct = await dbHelper.getProductByBarcode(barcode);

                  if (existingProduct != null) {
                    productCubit.updateData(existingProduct);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(
                          existingProduct: existingProduct,
                        ),
                      ),
                    );
                  } else {
                    // If the product doesn't exist, navigate to AddProductScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(),
                      ),
                    );
                  }
                }
              });
            },
          ),
          Center(child: Container())
        ],
      ),
    );
  }
}

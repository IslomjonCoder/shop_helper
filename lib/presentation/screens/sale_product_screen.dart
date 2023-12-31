import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shop_helper/business_logic/blocs/product_bloc.dart';
import 'package:shop_helper/data/service/local/database_helper.dart';

class SaleProductScreen extends StatefulWidget {
  const SaleProductScreen({super.key});

  @override
  State<SaleProductScreen> createState() => _SaleProductScreenState();
}

class _SaleProductScreenState extends State<SaleProductScreen> {
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
      appBar: AppBar(title: const Text('Sale Products')),
      body: Stack(
        children: [
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) async {
              print(state);
              if (state is ProductErrorState) {
                Fluttertoast.showToast(msg: 'Product not found!');
                await Future.delayed(const Duration(milliseconds: 600), () {
                  controller?.resumeCamera();
                });
              } else if (state is ProductLoadedState) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Product Sold')));
                Navigator.of(context).pop();
              }
            },
            child: QRView(
              overlay: QrScannerOverlayShape(),
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                this.controller = controller;
                // controller.toggleFlash();
                controller.scannedDataStream.listen((scanData) async {
                  if (scanData.code != null) {
                    await controller.stopCamera();
                    context.read<ProductBloc>().add(SaleProductEvent(scanData.code!));
                  }
                });
              },
            ),
          ),
          Center(child: Container())
        ],
      ),
    );
  }
}
//
// class GetBarcodeScreen extends StatefulWidget {
//   const GetBarcodeScreen({super.key});
//
//   @override
//   _GetBarcodeScreenState createState() => _GetBarcodeScreenState();
// }
//
// class _GetBarcodeScreenState extends State<GetBarcodeScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   final dbHelper = DatabaseHelper();
//
//   // Variable to track the flashlight status
//   bool isFlashOn = false;
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   // Function to toggle the flashlight
//   void toggleFlashlight() {
//     if (controller != null) {
//       if (isFlashOn) {
//         controller!.toggleFlash();
//         setState(() {
//           isFlashOn = false;
//         });
//       } else {
//         controller!.toggleFlash();
//         setState(() {
//           isFlashOn = true;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton:
//           FloatingActionButton(onPressed: toggleFlashlight, child: Icon(Icons.flash_on)),
//       appBar: AppBar(
//         title: const Text('Get Barcode'),
//       ),
//       body: Stack(
//         children: [
//           QRView(
//             overlay: QrScannerOverlayShape(),
//             key: qrKey,
//             onQRViewCreated: (QRViewController controller) {
//               this.controller = controller;
//               controller.scannedDataStream.listen((scanData) async {
//                 if (scanData.code != null) {
//                   final productCubit = context.read<ProductCubit>();
//                   final barcode = scanData.code!;
//                   productCubit.updateBarcode(barcode);
//                   await controller.stopCamera();
//
//                   // Check if the product exists in the database
//                   final existingProduct = await dbHelper.getProductByBarcode(barcode);
//
//                   if (existingProduct != null) {
//                     productCubit.updateData(existingProduct);
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AddProductScreen(
//                           existingProduct: existingProduct,
//                         ),
//                       ),
//                     );
//                   } else {
//                     // If the product doesn't exist, navigate to AddProductScreen
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AddProductScreen(),
//                       ),
//                     );
//                   }
//                 }
//               });
//             },
//           ),
//           Center(child: Container())
//         ],
//       ),
//     );
//   }
// }

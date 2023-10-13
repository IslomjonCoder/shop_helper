import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:shop_helper/business_logic/blocs/product_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_helper/business_logic/cubits/product_cubit.dart';
import 'package:shop_helper/presentation/screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductBloc(),
        ),
        BlocProvider<ProductCubit>(
          create: (context) => ProductCubit(),
        ),
      ],
      child: MaterialApp(
        theme: FlexThemeData.light(scheme: FlexScheme.greenM3, useMaterial3: true),
        // The Mandy red, dark theme.
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.greenM3,
          useMaterial3: true,
          // swapColors: true,
          // swapLegacyOnMaterial3: true,
          // tooltipsMatchBackground: true,
        ),
        // Use dark or light theme based on system setting.
        themeMode: ThemeMode.system,
        home: const HomeScreen(),

        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

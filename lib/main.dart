import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';

void main() {
  runApp(const MartApp());
}

class MartApp extends StatelessWidget {
  const MartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Mart App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/sign-in': (context) => const SignInScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

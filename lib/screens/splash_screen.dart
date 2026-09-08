import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Initialize AuthService
    await AuthService().init();
    
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      final authService = AuthService();
      // If user is logged in, go to home, otherwise go to login
      final route = authService.isLoggedIn ? '/home' : '/login';
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade600.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              'Mart App',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your favorite shopping destination',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
                strokeWidth: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

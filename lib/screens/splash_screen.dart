import 'package:flutter/material.dart';
import 'package:zygreen_air_purifier/screens/dashboard_screen.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to dashboard after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
             Icon(
              Icons.air,
              size: 100,
              color: Colors.white,
            ),
             SizedBox(height: 24),
            // App Name
             Text(
              'Zygreen Air',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 8),
             Text(
              'Breathe Clean, Live Green',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
             SizedBox(height: 48),
            // Loading Indicator
             CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zygreen_air_purifier/screens/dashboard_screen.dart';
import 'package:zygreen_air_purifier/screens/onboarding_screen.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';
import 'dart:async'; // Required for Timer

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Animation State Variables
  double _opacity = 0.0;
  double _logoSize = 200.0; // Initial size slightly smaller
  
  @override
  void initState() {
    super.initState();
    
    // 1. Trigger Animation after small delay for smooth entrance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
        _logoSize = 220.0; // Target size
      });
    });

    // 2. Check onboarding status and navigate
    _checkOnboardingAndNavigate();
  }

  Future<void> _checkOnboardingAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    // Add a small delay for the splash screen to be visible
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => isOnboardingCompleted 
            ? const DashboardScreen() 
            : const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // IMPROVEMENT 1: Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              Color(0xFF00C97E), // Slightly lighter shade of primary
            ],
          ),
        ),
        child: Stack(
          children: [
            // Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IMPROVEMENT 2: Animated Logo (Scale + Fade)
                  AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeOutExpo,
                    height: _logoSize,
                    child: AnimatedOpacity(
                      duration: const Duration(seconds: 1),
                      opacity: _opacity,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
       
                        ),
                        child: const Image(
                          image: AssetImage('assets/images/logo.png'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // IMPROVEMENT 3: Typography & Text Animation
                  AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: _opacity,
                    curve: Curves.easeIn,
                    child: Column(
                      children: [
                        const Text(
                          'ZyGreen',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40, // Slightly larger
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5, // Adds elegance
                            
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Breathe Clean, Live Green',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // IMPROVEMENT 4: Footer (Loader + Version)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const SizedBox(
                    width: 20, 
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Make sure these images exist in your assets folder and are declared in pubspec.yaml
  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to Zygreen',
      'description': 'Breathe cleaner air with our algal based smart air purifier solution.',
      'image': 'assets/images/onboarding1.jpg',
    },
    {
      'title': 'Real-time Air Quality',
      'description': 'Monitor your indoor air quality in real-time with detailed metrics.',
      'image': 'assets/images/onboarding2.jpg',
    },
    {
      'title': 'Smart Control',
      'description': 'Control your purifier remotely and get personalized recommendations.',
      'image': 'assets/images/onboarding3.jpg',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _onNext() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint, // A slightly smoother curve
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button aligned to top-right
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ),
            // Main Content (Image + Text)
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Section
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              _onboardingData[index]['image']!,
                              // Use a placeholder or error builder if needed
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image_not_supported, size: 100, color: Colors.grey[300]);
                              },
                              fit: BoxFit.contain,
                              // Give it a max height relative to screen for better scaling
                              height: size.height * 0.35, 
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Text Section
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                _onboardingData[index]['title']!,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColorDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _onboardingData[index]['description']!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Controls (Indicators + Button)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? theme.primaryColor
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Next/Get Started Button
                    SizedBox(
                      width: double.infinity,
                      height: 56, // Standard tall button height
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'Get Started'
                              : 'Next',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'widgets/onboarding_slide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _slides = [
    OnboardingSlide(
      imageAsset: 'assets/inventory.png',
      title: 'Manage Stock Easily',
      description: "Add, edit, and monitor items in a few taps.",
    ),
    OnboardingSlide(
      imageAsset: 'assets/sales.png',
      title: 'Quick Billing',
      description: "Fast checkout with barcode scanning and PDF bills.",
    ),
    OnboardingSlide(
      imageAsset: 'assets/analytics.png',
      title: 'Visualize Profits',
      description: "Track sales trends, profits, and top-sellers easily.",
    ),
    OnboardingSlide(
      imageAsset: 'assets/cloud.png',
      title: 'Secure Cloud Backup',
      description: "Google Drive backup keeps your data safe always.",
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: kTabScrollDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, i) => _slides[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => Container(
                  height: 8,
                  width: 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i
                        ? Colors.blueAccent
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 32,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: _goToLogin, child: const Text('Skip')),
                  ElevatedButton(
                    onPressed: _currentPage == _slides.length - 1
                        ? _goToLogin
                        : _next,
                    child: Text(
                      _currentPage == _slides.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

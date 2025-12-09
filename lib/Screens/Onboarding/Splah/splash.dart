import 'package:flutter/material.dart';
import 'package:inkspire/Screens/Onboarding/Splah/onboarding_sreen.dart';
import 'package:inkspire/Screens/Onboarding/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Check if user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return; // Check if widget is still mounted

    if (hasSeenOnboarding) {
      // User has seen onboarding, go to login
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Login(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            return FadeTransition(opacity: fade, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      // First time user, show onboarding
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            return FadeTransition(opacity: fade, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/images/logo.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

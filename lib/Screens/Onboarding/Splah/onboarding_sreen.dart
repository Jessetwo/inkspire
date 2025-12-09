import 'package:flutter/material.dart';
import 'package:inkspire/Screens/Onboarding/auth/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  // Mark onboarding as completed
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'hasSeenOnboarding',
      true,
    ); // Changed to match splash screen key

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for onboarding pages
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {});
            },
            children: const [
              OnboardingPage(
                title: "Welcome to Inkspire",
                description:
                    "Your Space to read, write, and share ideas that inspire. Dive into the world of creativity and expression",
                imagePath: "assets/images/Notebook.png",
              ),
              OnboardingPage(
                title: "Create & Share Effortlessly",
                description:
                    "Publish your thoughts, stories, or articles in just a few taps. Inkspire makes blogging simple, fun, and powerful.",
                imagePath: "assets/images/Storyboard.png",
              ),
              OnboardingPage(
                title: "Stay Connected & Inspired",
                description:
                    "Follow your favorite writers, discover trending posts, and be part of a community that values ideas and creativity.",
                imagePath: "assets/images/Brainstorming.png",
              ),
            ],
          ),
          // Page Indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: const WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  activeDotColor: Colors.blue,
                  dotColor: Colors.grey,
                ),
              ),
            ),
          ),
          // Get Started Button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: _completeOnboarding,
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff1E90FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for individual onboarding pages
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 300, width: 300),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Helper function to check if user has seen onboarding
// Use this in your main.dart or splash screen
class OnboardingChecker {
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  // Optional: Clear onboarding status (useful for testing)
  static Future<void> clearOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasSeenOnboarding');
  }
}

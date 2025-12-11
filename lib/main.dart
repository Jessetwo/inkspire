import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkspire/Screens/Onboarding/Splah/onboarding_sreen.dart';
import 'package:inkspire/Screens/Onboarding/Splah/splash.dart';
import 'package:inkspire/Screens/Onboarding/auth/login.dart';
import 'package:inkspire/Screens/main_screens/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inkspire',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1E90FF)),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const Splash(),
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => const Login(),
        '/home': (context) => const Homepage(),
      },
    );
  }
}

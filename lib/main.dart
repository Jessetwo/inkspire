import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inkspire/Screens/Onboarding/Splah/onboarding_sreen.dart';
import 'package:inkspire/Screens/Onboarding/Splah/splash.dart';
import 'package:inkspire/Screens/Onboarding/auth/login.dart';
import 'package:inkspire/Screens/main_screens/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const Splash(),
        '/onboarding': (context) => const OnboardingSreen(),
        '/login': (context) => const Login(),
        '/home': (context) => const Homepage(),
      },
    );
  }
}

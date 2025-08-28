import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/Screens/home_screen/home_screen.dart';
import 'package:flutter_application_1/Screens/home_screen/onboarding_screen/onboarding_Screens.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    } else if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  Gradient background for modern luxury feel
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF8E1),
              Color(0xFFFFFFFF),
            ], // Soft amber to white
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                    'assets/a-tailor-sitting-and-stitching-clothes-on-a-stitching-machine-with-an-inchtape-put-around-his-neck-vector-removebg-preview.png',
                    width: 220,
                    height: 220,
                  )
                  .animate()
                  .fadeIn(duration: 1200.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),

              const SizedBox(height: 20),

              // App Name
              Text(
                    "TailorMate",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF37474F), // BlueGrey (luxury dark)
                      letterSpacing: 1.5,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 1000.ms)
                  .moveY(begin: 20, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 12),

              // Tagline
              Text(
                    "Custom Stitching | Timeless Style",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFFF57C00), // Deep Orange accent
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.7,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 800.ms)
                  .slideY(begin: 0.5, end: 0),

              const SizedBox(height: 30),

              // Loading Spinner (with softer glow)
              const SpinKitFadingCircle(
                color: Color(0xFFFFB300), // Amber loader
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

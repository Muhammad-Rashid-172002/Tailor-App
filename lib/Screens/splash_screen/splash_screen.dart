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
      // First time user - show onboarding screen
      await prefs.setBool('isFirstTime', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    } else if (user != null) {
      // User is signed in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      // Not signed in - go to sign-in screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/a-tailor-sitting-and-stitching-clothes-on-a-stitching-machine-with-an-inchtape-put-around-his-neck-vector-removebg-preview.png',
              width: 250,
              height: 250,
            ),
            Text(
                  "TailorMate",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 1000.ms)
                .moveY(begin: 30, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 10),

            Text(
                  "Custom Stitching | Timeless Style",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                )
                .animate()
                .fadeIn(delay: 900.ms)
                .slideY(begin: 0.5, duration: 800.ms),
            SizedBox(height: 20),
            const SpinKitCircle(color: Colors.white, size: 50.0),
          ],
        ),
      ),
    );
  }
}

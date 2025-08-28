import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/Auth_module/signUp_Screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  bool isLoading = false;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Your personal tailor, now in your pocket",
      "description":
          "Book fittings, design your style,\nand get custom stitching all with a tap.",
      "image":
          "assets/a-tailor-sitting-and-stitching-clothes-on-a-stitching-machine-with-an-inchtape-put-around-his-neck-vector-removebg-preview.png",
    },
    {
      "title": "Tailored fashion, made easy.",
      "description":
          "From measurements to doorstep delivery,\nwe’ve stitched it all together.",
      "image": "assets/Adobe Express - file (1).png",
    },
    {
      "title": "Style that fits you perfectly.",
      "description":
          "Customize, track, and manage your tailoring orders anytime, anywhere.",
      "image": "assets/Adobe Express - file.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //  Luxury gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //  Image with animation
                          Image.asset(
                                onboardingData[index]['image']!,
                                height: 250,
                              )
                              .animate()
                              .fadeIn(duration: 800.ms)
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                curve: Curves.easeOut,
                              )
                              .moveY(begin: 40, end: 0, duration: 600.ms),

                          const SizedBox(height: 50),

                          //  Title
                          Text(
                                onboardingData[index]['title']!,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(
                                    0xFF37474F,
                                  ), // BlueGrey premium
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 900.ms)
                              .moveY(begin: 20, end: 0),

                          const SizedBox(height: 16),

                          //  Description
                          Text(
                                onboardingData[index]['description']!,
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  color: Colors.blueGrey[700],
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              )
                              .animate()
                              .fadeIn(delay: 600.ms, duration: 800.ms)
                              .slideY(begin: 0.3, end: 0),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// Dots Indicator
              SmoothPageIndicator(
                controller: _controller,
                count: onboardingData.length,
                effect: WormEffect(
                  activeDotColor: const Color(0xFFFFB300), // Amber highlight
                  dotColor: Colors.blueGrey.shade200,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),

              const SizedBox(height: 40),

              ///  Button / Loader
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isLoading
                    ? const SpinKitCircle(color: Color(0xFFFFB300), size: 45)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF37474F,
                          ), //  BlueGrey button
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black45,
                        ),
                        onPressed: () async {
                          if (_currentIndex < onboardingData.length - 1) {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            setState(() => isLoading = true);
                            await Future.delayed(const Duration(seconds: 2));
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          _currentIndex == onboardingData.length - 1
                              ? "LET'S GO"
                              : "NEXT",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white, //  Contrast on BlueGrey button
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

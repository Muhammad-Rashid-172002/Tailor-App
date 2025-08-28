import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth_module/signUp_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
          "Book fittings, design your style,\n and get custom stitching  all with a tap",
      "image":
          "assets/a-tailor-sitting-and-stitching-clothes-on-a-stitching-machine-with-an-inchtape-put-around-his-neck-vector-removebg-preview.png",
    },
    {
      "title": "Tailored fashion, made easy.",
      "description":
          "From measurements to doorstep delivery \n we’ve stitched it all together.",
      "image": "assets/Adobe Express - file (1).png",
    },
    {
      "title": "Style that fits you perfectly.",
      "description":
          "TCustomize, track, and manage your tailoring orders anytime, anywhere",
      "image": "assets/Adobe Express - file.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Image.asset(
                          onboardingData[index]['image']!,
                          height: 250,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          onboardingData[index]['title']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          onboardingData[index]['description']!,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
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
                activeDotColor: Colors.amber,
                dotColor: Colors.grey.shade300,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),

            const SizedBox(height: 30),

            /// LET'S GO Button or Loading Spinner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoading
                  ? const SpinKitCircle(color: Colors.white, size: 40)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        shadowColor: Colors.blueAccent,
                      ),
                      onPressed: () async {
                        if (_currentIndex < onboardingData.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          setState(() => isLoading = true);

                          // Simulate delay or loading logic
                          await Future.delayed(const Duration(seconds: 2));

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "LET'S GO",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

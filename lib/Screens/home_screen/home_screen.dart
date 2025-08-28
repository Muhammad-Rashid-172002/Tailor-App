import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Screens/home_screen/Pages/customerScreen.dart';
import 'package:flutter_application_1/Screens/home_screen/Pages/homePage.dart';
import 'package:flutter_application_1/Screens/home_screen/Pages/personscreen.dart';
import 'package:flutter_application_1/Screens/home_screen/Pages/receipt.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  final List<Widget> _pages = [
    HomePage(),
    CustomersScreen(),
    Receiptscreen(customerId: "CUSTOMER_DOC_ID"),
    Profile(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Press again to exit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 60, right: 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.amber, width: 1),
          ),
          backgroundColor: Colors.black87.withOpacity(0.9),
          duration: const Duration(seconds: 2),
          elevation: 8,
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exit = await _onWillPop();
        if (exit) {
          SystemNavigator.pop();
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // Luxury dark background
        body: IndexedStack(index: _currentIndex, children: _pages),

        // 🔥 Luxury Bottom Navigation
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Left side icons
                Row(
                  children: [
                    _navIcon(Icons.home_outlined, 0),
                    const SizedBox(width: 20),
                    _navIcon(Icons.people_outline, 1),
                  ],
                ),
                // Right side icons
                Row(
                  children: [
                    _navIcon(Icons.receipt_long_outlined, 2),
                    const SizedBox(width: 20),
                    _navIcon(Icons.person_outline, 3),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Custom Icon with Luxury Highlight
  Widget _navIcon(IconData icon, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? Colors.amber : Colors.grey.shade400,
        ),
      ),
    );
  }
}

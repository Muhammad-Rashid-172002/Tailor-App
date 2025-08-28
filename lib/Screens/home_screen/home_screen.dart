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
    DashboardScreen(),
    CustomersScreen(),
    Receiptscreen(),
    Profile(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAddScreenSafely() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text("Add Something")),
            body: Center(child: Text("Add Screen Placeholder")),
          ),
        ),
      );
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Press again to exit')));
      return Future.value(false);
    }
    return Future.value(true); // Exit app
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exit = await _onWillPop();
        if (exit) {
          SystemNavigator.pop(); // Closes the app
        }
        return false;
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.blueGrey,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.home_outlined,
                        color: _currentIndex == 0 ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () => _onTabTapped(0),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.people_outline,
                        color: _currentIndex == 1 ? Colors.amber : Colors.white,
                      ),
                      onPressed: () => _onTabTapped(1),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.receipt_long_outlined,
                        color: _currentIndex == 2 ? Colors.amber : Colors.white,
                      ),
                      onPressed: () => _onTabTapped(2),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.person_outline,
                        color: _currentIndex == 3 ? Colors.amber : Colors.white,
                      ),
                      onPressed: () => _onTabTapped(3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

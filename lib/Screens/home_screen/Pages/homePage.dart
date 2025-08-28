import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> tailors = [
    {
      "name": "Edelweiss Fashion House",
      "orders": "153",
      "image": "https://i.pravatar.cc/150?img=1",
      "desc": "Expert in wedding gowns, suits, and modern tailoring.",
    },
    {
      "name": "El Modiste",
      "orders": "145",
      "image": "https://i.pravatar.cc/150?img=2",
      "desc": "Premium tailoring service with custom-made dresses.",
    },
    {
      "name": "Classic Tailor",
      "orders": "120",
      "image": "https://i.pravatar.cc/150?img=3",
      "desc": "Specialized in men’s suits and formal wear.",
    },
  ];

  final List<Map<String, String>> news = [
    {
      "title": "Trendy Batik Outfits for Office Wear",
      "time": "2 months ago",
      "image": "https://picsum.photos/200/300",
      "content":
          "Discover the latest Batik office wear trends with stylish yet professional looks.",
    },
    {
      "title": "Date Night Outfit Ideas",
      "time": "5 months ago",
      "image": "https://picsum.photos/200/301",
      "content":
          "Explore chic and romantic outfit inspirations perfect for your next date night.",
    },
    {
      "title": "From Simple to Bold, 2022 Fashion Trends",
      "time": "7 months ago",
      "image": "https://picsum.photos/200/302",
      "content":
          "Fashion is evolving – from minimalism to bold patterns, see what’s trending.",
    },
  ];

  String userName = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      userName = user?.displayName ?? user?.email ?? "Guest";
    });
  }

  void _showTailorDialog(Map<String, String> tailor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          tailor["name"]!,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(tailor["image"]!),
            ),
            const SizedBox(height: 10),
            Text(
              "${tailor["orders"]} orders",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              tailor["desc"] ?? "No description",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewsDialog(Map<String, String> newsItem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 2), // White border
          borderRadius: BorderRadius.circular(16), // Optional rounded corners
        ),
        title: Text(
          newsItem["title"]!,
          style: const TextStyle(color: Colors.white), // White title text
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(newsItem["image"]!),
            const SizedBox(height: 10),
            Text(
              newsItem["time"]!,
              style: const TextStyle(color: Colors.white70), // Time text
            ),
            const SizedBox(height: 10),
            Text(
              newsItem["content"] ?? "No details",
              style: const TextStyle(color: Colors.white), // Content text
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.blueAccent), // Close button style
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        title: Text(
          "${_getGreeting()}, $userName ",
          style: const TextStyle(color: Colors.white),
        ),
      ),

      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Card
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (index) {
                          final today = DateTime.now();
                          final startOfWeek = today.subtract(
                            Duration(days: today.weekday - 1),
                          );
                          final currentDay = startOfWeek.add(
                            Duration(days: index),
                          );
                          final daysOfWeek = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                          final isToday =
                              today.day == currentDay.day &&
                              today.month == currentDay.month &&
                              today.year == currentDay.year;

                          if (isToday) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    daysOfWeek[index],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${currentDay.day}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                Text(
                                  daysOfWeek[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${currentDay.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              /// Recommended Tailors
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Recommended Tailors",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tailors.length,
                  itemBuilder: (context, index) {
                    final t = tailors[index];
                    return GestureDetector(
                      onTap: () => _showTailorDialog(t),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(t["image"]!),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t["name"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${t["orders"]} orders",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              /// Latest News
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Latest News",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    final n = news[index];
                    return GestureDetector(
                      onTap: () => _showNewsDialog(n),
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[850],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                n["image"]!,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n["title"]!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n["time"]!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

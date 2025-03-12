import 'package:flutter/material.dart';
import 'package:miniproj/pages/EventsScreen.dart';
import 'package:miniproj/pages/dashboard.dart';
import 'package:miniproj/pages/EventCreationScreen.dart'; // Ensure this import is present

class HomeScreen1 extends StatelessWidget {
  const HomeScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed the AppBar widget
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.tune),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Upcoming Events Section
              SectionTitle(title: "Upcoming Events"),
              const SizedBox(height: 10),
              SizedBox(
                height: 120, // Height for horizontal scroll
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    EventCard(title: "CS CUP 2025"),
                    EventCard(title: "Skate Club 2025"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Popular Now Section
              SectionTitle(title: "Popular Now"),
              const SizedBox(height: 10),
              SizedBox(
                height: 180, // Larger height for this section
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    PopularEventCard(title: "Film Fest Event"),
                    PopularEventCard(title: "Tech Symposium"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recommended Section
              SectionTitle(title: "Recommendations for you"),
              const SizedBox(height: 10),
              Column(
                children: [
                  RecommendationCard(title: "Photoshop Workshop - 2025"),
                  RecommendationCard(title: "CYBOTS"),
                  RecommendationCard(title: "Xtreme Talks"),
                  RecommendationCard(title: "Career Request 1.0 2025"),
                ],
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const EventCreationScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EventsScreen()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileDashboard()));
          }
        },
      ),
    );
  }
}

// Section Title Widget
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () {}, child: const Text("See All")),
      ],
    );
  }
}

// Event Card (for upcoming events)
class EventCard extends StatelessWidget {
  final String title;
  const EventCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child:
                Image.asset("assets/event_placeholder.png", fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: () {}, child: const Text("Join")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Popular Event Card
class PopularEventCard extends StatelessWidget {
  final String title;
  const PopularEventCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.asset("assets/popular_event_placeholder.png",
                fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// Recommendation Card
class RecommendationCard extends StatelessWidget {
  final String title;
  const RecommendationCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)
        ],
      ),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

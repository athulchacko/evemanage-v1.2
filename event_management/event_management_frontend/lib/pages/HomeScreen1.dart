import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
//import 'package:miniproj/pages/EventsScreen.dart';
import 'package:miniproj/pages/Profiledashboard.dart';
import 'package:miniproj/pages/EventCreationScreen.dart';
import 'package:miniproj/pages/AttendeeRegistrationScreen.dart';
import 'package:miniproj/pages/UserEventManagementScreen.dart';

class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({super.key});

  @override
  HomeScreen1State createState() => HomeScreen1State();
}

class HomeScreen1State extends State<HomeScreen1> {
  List<dynamic> upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    fetchUpcomingEvents();
  }

  // ✅ Fetch approved events from backend
  Future<void> fetchUpcomingEvents() async {
    const String apiUrl = "http://localhost:5000/api/events/approved";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          upcomingEvents = json.decode(response.body);
        });
      } else {
        print("❌ Failed to fetch events: ${response.statusCode}");
      }
    } catch (error) {
      print("🔥 Error fetching events: $error");
    }
  }

  // ✅ Decode Base64 image (if available)
  Widget decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Image.asset(
        "assets/images/event_placeholder.png",
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity);
    } catch (e) {
      return const Text("Invalid Image Format");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              // Upcoming Events Section (VERTICAL SCROLL)
              const SectionTitle(title: "Upcoming Events"),
              const SizedBox(height: 10),

              // 🔹 Vertical ListView with scrollable behavior
              upcomingEvents.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingEvents.length,
                      itemBuilder: (context, index) {
                        var event = upcomingEvents[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: EventCard(
                            title: event['eventName'],
                            eventId: event['_id'],
                            eventThumbnail: event['eventThumbnail'],
                          ),
                        );
                      },
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
            MaterialPageRoute(builder: (context) => const EventCreationScreen()),
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
                MaterialPageRoute(builder: (context) => const UserEventManagementScreen()));
          } else if (index == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileDashboard()));
          }
        },
      ),
    );
  }
}

// ✅ Section Title Widget
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () {}, child: const Text("See All")),
      ],
    );
  }
}

// ✅ Event Card (for upcoming events)
class EventCard extends StatelessWidget {
  final String title;
  final String eventId;
  final String? eventThumbnail;

  const EventCard({super.key, required this.title, required this.eventId, this.eventThumbnail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ✅ Full width
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: eventThumbnail != null
                ? decodeBase64Image(eventThumbnail!)
                : Image.asset(
                    "assets/images/event_placeholder.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 150,
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (eventId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendeeRegistrationScreen(eventId: eventId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Error: Event ID is invalid")),
                  );
                }
              },
              child: const Text("Join"),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Decode Base64 image (for thumbnails)
  Widget decodeBase64Image(String base64String) {
    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity);
    } catch (e) {
      return const Text("Invalid Image Format");
    }
  }
}

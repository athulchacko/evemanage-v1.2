import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool showUpcoming = true; // Controls the tab state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Events", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the home page
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), // Three-dot menu
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Toggle Button for Upcoming & Past Events
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton("UPCOMING", true),
                const SizedBox(width: 10),
                _buildToggleButton("PAST EVENTS", false),
              ],
            ),
          ),

          // Display Content Based on Selection
          Expanded(
            child: showUpcoming ? _buildUpcomingEvents() : _buildPastEvents(),
          ),
        ],
      ),
    );
  }

  // Toggle Button Widget
  Widget _buildToggleButton(String text, bool isUpcoming) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showUpcoming = isUpcoming;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: showUpcoming == isUpcoming ? Colors.black87 : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: showUpcoming == isUpcoming ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Upcoming Events List (Empty State)
  Widget _buildUpcomingEvents() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(" assets/images/eventtime.jpg", height: 150), // Add an image
        const SizedBox(height: 20),
        const Text(
          "No Upcoming Event",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text("No Result Show", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),

        // Explore Events Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/explore-events');
          },
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          label: const Text("Explore Events",
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Past Events Placeholder (Future Implementation)
  Widget _buildPastEvents() {
    return const Center(
      child: Text("Past events will be displayed here."),
    );
  }
}

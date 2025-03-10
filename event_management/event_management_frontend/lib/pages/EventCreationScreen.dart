import 'package:flutter/material.dart';

class EventCreationScreen extends StatelessWidget {
  const EventCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Management System"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildEventButton(context, Icons.add, "Create Event", '/custom-event'),
                _buildEventButton(context, Icons.group, "Workshop", '/create-workshop'),
                _buildEventButton(context, Icons.music_note, "Music", '/create-music-event'),
                _buildEventButton(context, Icons.sports, "Sports", '/create-sports-event'),
                _buildEventButton(context, Icons.business, "Conference", '/create-conference'),
                _buildEventButton(context, Icons.computer, "Webinar", '/create-webinar'),
              ],
            ),
            const SizedBox(height: 30),
            
            // Back Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context); // Go back to the Profile Dashboard
              },
              child: const Text("Back", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for Creating Event Buttons
  Widget _buildEventButton(BuildContext context, IconData icon, String title, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        children: [
          Icon(icon, size: 60, color: Colors.black87),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

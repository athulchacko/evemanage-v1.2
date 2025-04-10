import 'package:flutter/material.dart';

class EventPendingScreen extends StatelessWidget {
  final String eventName;
  final String location;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String description;

  const EventPendingScreen({
    Key? key,
    required this.eventName,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Submission"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.orange, size: 100),
            const SizedBox(height: 20),
            const Text(
              "Your event is under review!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Event: $eventName\nLocation: $location\nDate: $startDate - $endDate\nTime: $startTime - $endTime\n\n$description",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Text(
              "An admin will review your event. If approved, you'll receive the join link via email.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class EventSuccessScreen extends StatelessWidget {
  final String eventName;
  final String joinLink;

  const EventSuccessScreen({
    Key? key,
    required this.eventName,
    required this.joinLink,
  }) : super(key: key);

  // Function to open the join link in a browser
  void _launchURL(BuildContext context) async {
    final Uri url = Uri.parse(joinLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the link")),
      );
    }
  }

  // Function to copy the join link to clipboard
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: joinLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Join link copied!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Event Created", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success Icon
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),

            // Success Message
            const Text(
              "Event Created Successfully!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Event Name Display
            Text(
              "Event: $eventName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Join Link Button
            ElevatedButton.icon(
              onPressed: () => _launchURL(context),
              icon: const Icon(Icons.link, color: Colors.white),
              label: const Text("Join Event"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            const SizedBox(height: 10),

            // Copy Link Button
            OutlinedButton.icon(
              onPressed: () => _copyToClipboard(context),
              icon: const Icon(Icons.copy, color: Colors.black),
              label: const Text("Copy Link"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            const SizedBox(height: 30),

            // Back to Home Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back to Home", style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

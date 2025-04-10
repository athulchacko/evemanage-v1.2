import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';

class UserEventManagementScreen extends StatefulWidget {
  const UserEventManagementScreen({super.key});

  @override
  _UserEventManagementScreenState createState() => _UserEventManagementScreenState();
}

class _UserEventManagementScreenState extends State<UserEventManagementScreen> {
  List<dynamic> userEvents = [];
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  // 🔹 Fetch logged-in user email
  Future<void> _fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
      fetchUserEvents();
    }
  }

  // 🔹 Fetch events created by the logged-in user
  Future<void> fetchUserEvents() async {
    if (userEmail == null) return;

    final String apiUrl = "http://localhost:5000/api/events/user-events/$userEmail";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          userEvents = json.decode(response.body);
        });
      } else {
        print("❌ Failed to fetch events: ${response.statusCode}");
      }
    } catch (error) {
      print("🔥 Error fetching events: $error");
    }
  }

  // 🔹 Delete an event
  Future<void> _deleteEvent(String eventId) async {
    final String apiUrl = "http://localhost:5000/api/events/delete/$eventId";

    try {
      final response = await http.delete(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Event deleted successfully!")));
        fetchUserEvents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Failed to delete event")));
      }
    } catch (error) {
      print("🔥 Error deleting event: $error");
    }
  }

  // 🔹 Open event details page
  void _openEventDetails(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(eventId: eventId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Your Events")),
      body: userEmail == null
          ? const Center(child: CircularProgressIndicator())
          : userEvents.isEmpty
              ? const Center(child: Text("No events found"))
              : ListView.builder(
                  itemCount: userEvents.length,
                  itemBuilder: (context, index) {
                    var event = userEvents[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(event['eventName'] ?? "Unknown Event"),
                        subtitle: Text("Date: ${event['startDate'] ?? 'N/A'}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(event['_id']),
                        ),
                        onTap: () => _openEventDetails(event['_id']),
                      ),
                    );
                  },
                ),
    );
  }
}

// 📌 Event Details Screen
class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  List<dynamic> attendees = [];

  @override
  void initState() {
    super.initState();
    fetchAttendees();
  }

  // 🔹 Fetch attendees
  Future<void> fetchAttendees() async {
    final String apiUrl = "http://localhost:5000/api/attendees/${widget.eventId}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          attendees = json.decode(response.body);
        });
      } else {
        print("❌ Failed to fetch attendees: ${response.statusCode}");
      }
    } catch (error) {
      print("🔥 Error fetching attendees: $error");
    }
  }

  // 🔹 Remove an attendee
  Future<void> removeAttendee(String attendeeId) async {
    final String apiUrl = "http://localhost:5000/api/attendees/remove/$attendeeId";

    try {
      final response = await http.delete(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Attendee removed!")));
        fetchAttendees();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Failed to remove attendee")));
      }
    } catch (error) {
      print("🔥 Error removing attendee: $error");
    }
  }

  // 🔹 View payment screenshot
  void _viewPaymentScreenshot(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No payment screenshot available.")),
      );
      return;
    }

    try {
      Uint8List bytes = base64Decode(base64Image);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageViewer(imageBytes: bytes),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Invalid image format.")),
      );
      print("🔥 Error decoding base64 image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Details")),
      body: attendees.isEmpty
          ? const Center(child: Text("No attendees yet"))
          : ListView.builder(
              itemCount: attendees.length,
              itemBuilder: (context, index) {
                var attendee = attendees[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(attendee['name'] ?? "Unknown Attendee"),
                    subtitle: Text("Email: ${attendee['email'] ?? 'N/A'}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeAttendee(attendee['_id']),
                    ),
                    onTap: () {
                      if (attendee['paymentProof'] != null) {
                        _viewPaymentScreenshot(attendee['paymentProof']);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

// 🔹 Full-Screen Image Viewer for Zooming
class FullScreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;

  const FullScreenImageViewer({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: MemoryImage(imageBytes),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained * 1,
          maxScale: PhotoViewComputedScale.covered * 2.5,
        ),
      ),
    );
  }
}

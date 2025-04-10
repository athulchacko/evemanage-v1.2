import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

// ✅ API Base URL
const String baseUrl = "http://localhost:5000"; 

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<List<Map<String, dynamic>>> pendingEvents;

  @override
  void initState() {
    super.initState();
    pendingEvents = fetchPendingEvents();
  }

  // ✅ Fetch pending events
  Future<List<Map<String, dynamic>>> fetchPendingEvents() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/api/events/pending"))
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception("Failed to load pending events: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching pending events: $e");
    }
  }

  // ✅ Approve or reject an event
  Future<void> updateEventStatus(String eventId, String status) async {
    try {
      final String apiUrl = status == "approved"
          ? "$baseUrl/api/admin/approve/$eventId"
          : "$baseUrl/api/admin/reject/$eventId"; 

      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": status}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Event $status successfully!")),
        );
        setState(() {
          pendingEvents = fetchPendingEvents();
        });
      } else {
        throw Exception("Failed to update event status");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating event status: $e")),
      );
    }
  }

  // ✅ Display Image with Zoom Feature
  Widget decodeBase64Image(String? base64String, String imageTitle) {
    if (base64String == null || base64String.isEmpty) {
      return const Text("No Image Available");
    }
    try {
      Uint8List bytes = base64Decode(base64String);
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImageViewer(imageBytes: bytes, title: imageTitle),
            ),
          );
        },
        child: Image.memory(bytes, height: 150, fit: BoxFit.cover),
      );
    } catch (e) {
      return const Text("Invalid Image Format");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard - Pending Events")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: pendingEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No pending events"));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Event Name: ${event["eventName"]}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text("Created By: ${event["createdBy"]}"),
                      const SizedBox(height: 5),
                      Text("Date: ${event["startDate"]} - ${event["endDate"]}"),
                      const SizedBox(height: 5),
                      Text("Time: ${event["startTime"]} - ${event["endTime"]}"),
                      const SizedBox(height: 5),
                      Text("Location: ${event["location"]}"),
                      const SizedBox(height: 10),

                      // ✅ Display ID Card Image with Zoom Feature
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ID Card Image:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          decodeBase64Image(event["idCardImage"], "ID Card Image"),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ✅ Display Event Thumbnail Image with Zoom Feature
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Event Thumbnail:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          decodeBase64Image(event["eventThumbnail"], "Event Thumbnail"),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => updateEventStatus(event["_id"], "approved"),
                            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.green),
                            child: const Text("Approve"),
                          ),
                          ElevatedButton(
                            onPressed: () => updateEventStatus(event["_id"], "rejected"),
                            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red),
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ✅ Full-Screen Image Viewer with Zoom Feature
class FullScreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;
  final String title;

  const FullScreenImageViewer({super.key, required this.imageBytes, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: PhotoView(
          imageProvider: MemoryImage(imageBytes),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}

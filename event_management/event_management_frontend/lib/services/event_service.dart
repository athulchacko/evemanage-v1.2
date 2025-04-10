import 'dart:convert';
import 'package:miniproj/utils/config.dart'; // Import config for BASE_URL
import 'package:miniproj/services/api_service.dart'; // Import ApiService

class EventService {
  // ✅ Fetch all events
  static Future<List<dynamic>> fetchEvents() async {
    try {
      final response = await ApiService.get("$BASE_URL/events"); // Added /events endpoint
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return JSON list of events
      } else {
        throw Exception("Failed to load events: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Error fetching events: $error");
    }
  }

  // ✅ Create a new event
  static Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    try {
      final response = await ApiService.post("$BASE_URL/create", eventData);
      if (response.statusCode == 201) {
        return {"success": true, "message": "Event created successfully"};
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error["error"] ?? "Failed to create event"
        };
      }
    } catch (error) {
      return {"success": false, "message": "Error creating event: $error"};
    }
  }
}
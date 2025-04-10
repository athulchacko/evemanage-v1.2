import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VendorScreen extends StatefulWidget {
  @override
  _VendorScreenState createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  Map<String, List<dynamic>> categorizedVendors = {};

  @override
  void initState() {
    super.initState();
    fetchVendors();
  }

  // ✅ Fetch vendor details from the backend API
  Future<void> fetchVendors() async {
    const String apiUrl =
        "http://localhost:5000/api/vendors"; // Replace with actual backend URL

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> vendors = json.decode(response.body);

        // Group vendors by category
        Map<String, List<dynamic>> groupedVendors = {};
        for (var vendor in vendors) {
          String category = vendor['category'] ?? 'Others';
          if (!groupedVendors.containsKey(category)) {
            groupedVendors[category] = [];
          }
          groupedVendors[category]!.add(vendor);
        }

        setState(() {
          categorizedVendors = groupedVendors;
        });
      } else {
        print("❌ Failed to fetch vendors: ${response.statusCode}");
      }
    } catch (error) {
      print("🔥 Error fetching vendors: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vendor Details")),
      body: categorizedVendors.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : ListView(
              children: categorizedVendors.entries.map((entry) {
                String category = entry.key;
                List<dynamic> vendors = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    ...vendors.map((vendor) {
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(vendor['name'],
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("📍 Location: ${vendor['location']}"),
                              Text("📞 Contact: ${vendor['contact']}"),
                              Text("🏆 Rating: ⭐ ${vendor['rating']}"),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
    );
  }
}

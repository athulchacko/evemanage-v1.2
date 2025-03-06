import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WorkshopEventScreen extends StatefulWidget {
  @override
  _WorkshopEventScreenState createState() => _WorkshopEventScreenState();
}

class _WorkshopEventScreenState extends State<WorkshopEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? _image; // Store the selected image

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Check file size (max 10MB)
      int fileSize = await imageFile.length();
      if (fileSize <= 10 * 1024 * 1024) { // 10MB limit
        setState(() {
          _image = imageFile;
        });
      } else {
        _showErrorDialog("File size must be less than 10MB.");
      }
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  // Function to submit the form
  void _publishEvent() {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        _showErrorDialog("Please upload an event thumbnail.");
        return;
      }

      // Simulating event creation (Replace with Firebase API or backend logic)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workshop Event Published Successfully!")),
      );

      // Clear the form after publishing
      eventNameController.clear();
      locationController.clear();
      startDateController.clear();
      endDateController.clear();
      startTimeController.clear();
      endTimeController.clear();
      descriptionController.clear();
      setState(() {
        _image = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Workshop Header
              Image.asset('assets/images/workshop.png', height: 80), // Workshop Icon
              const SizedBox(height: 10),
              const Text(
                "WORKSHOP",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Event Details Input Fields
              _buildTextField(eventNameController, "Event Name*", "Enter event name"),
              _buildTextField(locationController, "Location*", "Enter location"),
              _buildTextField(startDateController, "Start Date*", "YYYY-MM-DD"),
              _buildTextField(endDateController, "End Date*", "YYYY-MM-DD"),
              _buildTextField(startTimeController, "Start Time*", "HH:MM AM/PM"),
              _buildTextField(endTimeController, "End Time*", "HH:MM AM/PM"),
              _buildTextField(descriptionController, "Description", "Enter event details", maxLines: 3),

              const SizedBox(height: 20),

              // Image Picker
              const Text("Event Thumbnail", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, size: 40, color: Colors.black),
                            Text("Max size 10MB", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Publish Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _publishEvent,
                child: const Text("PUBLISH YOUR EVENT", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to Build Text Fields
  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          return null;
        },
      ),
    );
  }
}

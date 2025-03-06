import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Check file size (max 10MB)
      int fileSize = await imageFile.length();
      if (fileSize <= 10 * 1024 * 1024) {
        // 10MB limit
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
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),
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
        const SnackBar(content: Text("Event Published Successfully!")),
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {},
                  child: const Text("CREATE YOUR EVENT",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // Event Name
              _buildTextField("EVENT NAME*", eventNameController),

              // Location
              _buildTextField("LOCATION*", locationController),

              // Start & End Date
              _buildTextField("START DATE*", startDateController),
              _buildTextField("END DATE*", endDateController),

              // Start & End Time
              _buildTextField("START TIME*", startTimeController),
              _buildTextField("END TIME*", endTimeController),

              // Description
              _buildTextField("DESCRIPTION", descriptionController,
                  maxLines: 3),

              // Event Thumbnail
              const SizedBox(height: 20),
              const Text("EVENT THUMBNAIL",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 50, color: Colors.black),
                              Text("MAX SIZE 10 MB*",
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      )
                    : Image.file(_image!,
                        width: double.infinity, height: 150, fit: BoxFit.cover),
              ),
              const SizedBox(height: 30),

              // Publish Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _publishEvent,
                  child: const Text("PUBLISH YOUR EVENT",
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField Widget
  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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

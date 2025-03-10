import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CulturalEventScreen extends StatefulWidget {
  const CulturalEventScreen({super.key});

  @override
  _CulturalEventScreenState createState() => _CulturalEventScreenState();
}

class _CulturalEventScreenState extends State<CulturalEventScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      int fileSize = await imageFile.length();

      if (fileSize <= 10 * 1024 * 1024) { // 10MB limit
        setState(() => _image = imageFile);
      } else {
        _showErrorDialog("File size must be less than 10MB.");
      }
    }
  }

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

  void _publishEvent() {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        _showErrorDialog("Please upload an event thumbnail.");
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cultural Event Created Successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cultural Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Event Name"),
              _buildTextField("Location"),
              _buildTextField("Start Date"),
              _buildTextField("End Date"),
              _buildTextField("Start Time"),
              _buildTextField("End Time"),
              _buildTextField("Description"),
              const SizedBox(height: 20),

              // Image Upload Section
              Text("Event Thumbnail", style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? const Icon(Icons.add, size: 50, color: Colors.grey)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),

              // Publish Button
              ElevatedButton(
                onPressed: _publishEvent,
                child: const Text("PUBLISH YOUR EVENT"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? "This field is required" : null,
      ),
    );
  }
}

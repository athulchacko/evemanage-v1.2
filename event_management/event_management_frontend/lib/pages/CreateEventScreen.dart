import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:miniproj/pages/EventPendingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import EventService
import 'package:http/http.dart' as http;

// Get current logged-in user
User? user = FirebaseAuth.instance.currentUser;

String userEmail = user?.email ?? "Unknown";

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isPaid = false;
  bool isLoading = false; // Added loading state

  File? _idCardImage;
  Uint8List? _webIdCardImage;
  File? _thumbnailImage; // File for event thumbnail (mobile)
  Uint8List? _webThumbnailImage; // Uint8List for event thumbnail (web)

  Future<void> _pickImage({required bool isThumbnail}) async {
    try {
      if (kIsWeb) {
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null) {
          setState(() {
            if (isThumbnail) {
              _webThumbnailImage = result.files.first.bytes;
            } else {
              _webIdCardImage = result.files.first.bytes;
            }
          });
        }
      } else {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            if (isThumbnail) {
              _thumbnailImage = File(pickedFile.path);
            } else {
              _idCardImage = File(pickedFile.path);
            }
          });
        }
      }
    } catch (e) {
      _showErrorDialog("Failed to pick an image: $e");
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate
        ? (startDate ?? DateTime.now())
        : (endDate ?? DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog("Please fill all required fields.");
      return;
    }

    if (startDate == null ||
        endDate == null ||
        startTime == null ||
        endTime == null) {
      _showErrorDialog("Please select date and time.");
      return;
    }

    // Check if end date/time is after start date/time
    final startDateTime = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      _showErrorDialog("End date/time must be after start date/time.");
      return;
    }

    // Check if ID card and thumbnail are provided
    if ((_idCardImage == null && _webIdCardImage == null) ||
        (_thumbnailImage == null && _webThumbnailImage == null)) {
      _showErrorDialog("Please upload ID card and event thumbnail images.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> eventData = {
      "eventName": eventNameController.text,
      "location": locationController.text,
      "startDate": startDate!.toIso8601String(),
      "endDate": endDate!.toIso8601String(),
      "startTime": startTime!.format(context),
      "endTime": endTime!.format(context),
      "description": descriptionController.text,
      "createdBy": FirebaseAuth.instance.currentUser?.email ?? "Unknown", // Replace with actual user ID when available
      "isPaid": isPaid,
      "idCardImage": _idCardImage != null
          ? base64Encode(await _idCardImage!.readAsBytes())
          : (_webIdCardImage != null ? base64Encode(_webIdCardImage!) : ""),
      "eventThumbnail": _thumbnailImage != null
      ? base64Encode(await _thumbnailImage!.readAsBytes()) // ✅ FIXED
      : (_webThumbnailImage != null ? base64Encode(_webThumbnailImage!) : ""),
    };

    try {
      final url = Uri.parse(
          'http://localhost:5000/api/events/create'); // Replace with your API URL

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(eventData),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Event Created Successfully!")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPendingScreen(
              eventName: eventNameController.text,
              location: locationController.text,
              startDate: startDate!.toLocal().toString().split(' ')[0],
              endDate: endDate!.toLocal().toString().split(' ')[0],
              startTime: startTime!.format(context),
              endTime: endTime!.format(context),
              description: descriptionController.text.isNotEmpty
                  ? descriptionController.text
                  : "No description provided",
            ),
          ),
        );
      } else {
        final responseBody = jsonDecode(response.body);
        _showErrorDialog(responseBody["message"] ?? "Failed to create event.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Error during API: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: (value) {
        if (label.endsWith('*') && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDatePickerField(
      String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: date != null ? "${date.toLocal()}".split(' ')[0] : '',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a date';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildTimePickerField(
      BuildContext context, String label, TimeOfDay? time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.access_time),
          ),
          controller: TextEditingController(
            text: time != null ? time.format(context) : '',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a time';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _imagePicker(
      String label, File? image, Uint8List? webImage, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration:
                BoxDecoration(border: Border.all(color: Colors.black54)),
            child: image != null
                ? Image.file(image, fit: BoxFit.cover)
                : webImage != null
                    ? Image.memory(webImage, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(Icons.add, size: 50, color: Colors.black)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 169, 173, 239),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add the heading
                    const Text(
                      "CREATE EVENT",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30), // Add spacing after the heading

                    // Event Name
                    _buildTextField("EVENT NAME*", eventNameController),
                    const SizedBox(height: 20), // Add spacing between fields

                    // Location
                    _buildTextField("LOCATION*", locationController),
                    const SizedBox(height: 20),

                    // Start Date
                    _buildDatePickerField("START DATE*", startDate,
                        () => _selectDate(context, true)),
                    const SizedBox(height: 20),

                    // End Date
                    _buildDatePickerField("END DATE*", endDate,
                        () => _selectDate(context, false)),
                    const SizedBox(height: 20),

                    // Start Time
                    _buildTimePickerField(context, "START TIME*", startTime,
                        () => _selectTime(context, true)),
                    const SizedBox(height: 20),

                    // End Time
                    _buildTimePickerField(context, "END TIME*", endTime,
                        () => _selectTime(context, false)),
                    const SizedBox(height: 20),

                    // Description
                    _buildTextField("DESCRIPTION", descriptionController,
                        maxLines: 3),
                    const SizedBox(height: 20),

                    // ID Card Image Picker
                    _imagePicker("UPLOAD ID CARD*", _idCardImage,
                        _webIdCardImage, () => _pickImage(isThumbnail: false)),
                    const SizedBox(height: 20),

                    // Event Thumbnail Picker
                    _imagePicker(
                        "UPLOAD EVENT THUMBNAIL*",
                        _thumbnailImage,
                        _webThumbnailImage,
                        () => _pickImage(isThumbnail: true)),
                    const SizedBox(height: 20),

                    // Paid Event Toggle
                    SwitchListTile(
                      title: const Text("Is this a paid event?"),
                      value: isPaid,
                      onChanged: (bool value) {
                        setState(() {
                          isPaid = value;
                        });
                      },
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: isLoading ? null : _submitEvent,
                        child: const Text("SUBMIT FOR APPROVAL",
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

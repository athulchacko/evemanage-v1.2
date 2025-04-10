import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AttendeeRegistrationScreen extends StatefulWidget {
  final String eventId;

  const AttendeeRegistrationScreen({super.key, required this.eventId});

  @override
  _AttendeeRegistrationScreenState createState() => _AttendeeRegistrationScreenState();
}

class _AttendeeRegistrationScreenState extends State<AttendeeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController branchYearController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isPaid = false; 
  File? _paymentProof;
  Uint8List? _webpaymentProof;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  /// ✅ Fetch Approved Event Details
  Future<void> _fetchEventDetails() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/events/approved/${widget.eventId}'));

      if (response.statusCode == 200) {
        final eventData = jsonDecode(response.body);
        setState(() {
          isPaid = eventData['isPaid'] ?? false;
        });
      } else if (response.statusCode == 404) {
        _showErrorDialog("⚠️ Event not found or not approved.");
      } else {
        _showErrorDialog("⚠️ Failed to fetch event details. Try again later.");
      }
    } catch (e) {
      _showErrorDialog("🔥 Network error: $e");
    }
  }

  /// ✅ Pick Payment Screenshot (Web & Mobile Support)
  Future<void> _pickpaymentProof() async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.first.bytes != null) {
          setState(() {
            _webpaymentProof = result.files.first.bytes!;
          });
        }
      } else {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _paymentProof = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      _showErrorDialog("⚠️ Failed to pick an image: $e");
    }
  }

  /// ✅ Register Attendee
  Future<void> _registerAttendee() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog("⚠️ Please fill all required fields.");
      return;
    }

    // 🔹 Ensure payment proof for paid events
    if (isPaid && _paymentProof == null && _webpaymentProof == null) {
      _showErrorDialog("⚠️ Payment screenshot is required for paid events.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> registrationData = {
        "eventId": widget.eventId,
        "name": nameController.text,
        "branchCode": branchYearController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "isPaid": isPaid,
        "paymentProof": isPaid
            ? (_paymentProof != null
                ? base64Encode(await _paymentProof!.readAsBytes())
                : (_webpaymentProof != null ? base64Encode(_webpaymentProof!) : ""))
            : null,
      };

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/attendees/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registrationData),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Registered Successfully!")),
        );
        Navigator.pop(context);
      } else {
        final responseBody = jsonDecode(response.body);
        _showErrorDialog(responseBody["message"] ?? "⚠️ Registration failed.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("🔥 Error during API call: $e");
    }
  }

  /// ✅ Show Error Dialog
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

  /// ✅ Build Text Input Field
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  /// ✅ Payment Screenshot Picker
  Widget _imagePicker(String label, File? image, Uint8List? webImage, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
            child: image != null
                ? Image.file(image, fit: BoxFit.cover)
                : webImage != null
                    ? Image.memory(webImage, fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.add, size: 50, color: Colors.black)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register for Event"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField("Full Name*", nameController),
                  const SizedBox(height: 20),
                  _buildTextField("Branch & Year Code (e.g., R6A, R8A)*", branchYearController),
                  const SizedBox(height: 20),
                  _buildTextField("Email*", emailController),
                  const SizedBox(height: 20),
                  _buildTextField("Phone Number*", phoneController),
                  const SizedBox(height: 20),

                  // 🔹 Payment Screenshot Option (Only if event is paid)
                  if (isPaid) _imagePicker("Upload Payment Screenshot*", _paymentProof, _webpaymentProof, _pickpaymentProof),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: isLoading ? null : _registerAttendee,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("REGISTER", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:miniproj/pages/VendorScreen.dart';

class ProfileDashboard extends StatefulWidget {
  const ProfileDashboard({super.key});

  @override
  _ProfileDashboardState createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends State<ProfileDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = "Loading...";
  String userEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        setState(() {
          userEmail = user.email ?? "No Email";
        });

        // Fetch additional user details from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc.get("name") ?? "No Name";
          });
        }
      }
    } catch (e) {
      print("Error fetching user details: $e");
      setState(() {
        userName = "Error";
        userEmail = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(221, 54, 118, 167),
      ),
      body: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/profilepic.jpeg'), // Change this to a network image if needed
            ),
            decoration:
                const BoxDecoration(color: Color.fromARGB(221, 26, 106, 163)),
          ),
          _buildListTile(Icons.event, 'Create Event', () {
            Navigator.pushNamed(context, '/create-event');
          }),
          _buildListTile(Icons.calendar_today, 'Calendar', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          }),
          _buildListTile(Icons.business, 'Vendor', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VendorScreen()),
            );
          }),
          _buildListTile(Icons.exit_to_app, 'Sign Out', () async {
            await _auth.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          }),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarScreen()),
              );
            },
            child: Text("Open Calendar"),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(221, 38, 14, 200)),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
        ],
      ),
    );
  }
}

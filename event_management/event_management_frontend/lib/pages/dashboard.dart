import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miniproj/pages/CreateEventScreen.dart';
import 'package:table_calendar/table_calendar.dart';


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

      if (user == null) {
        setState(() {
          userName = "Guest User";
          userEmail = "No Email";
        });
        return;
      }

      setState(() {
        userEmail = user.email ?? "No Email";
      });

      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userName = userDoc.get("name") ?? "No Name Provided";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error Loading User";
        userEmail = "Error Loading Email";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/profilepic.jpeg'),
            ),
            decoration: const BoxDecoration(color: Color.fromARGB(221, 30, 113, 168)),
          ),
          _buildListTile(Icons.event, 'Create Event', () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CreateEventScreen()));
          }),
          _buildListTile(Icons.calendar_today, 'Calendar', _showCalendar),
          _buildListTile(Icons.star, 'Starred', () {}),
          _buildListTile(Icons.business, 'Vendor', () {}),
          _buildListTile(Icons.help, 'Help & FAQs', () {}),
          _buildListTile(Icons.exit_to_app, 'Sign Out', () async {
            await _auth.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showCalendar() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select a Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selectedDay, focusedDay) {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

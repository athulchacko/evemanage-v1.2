import 'package:flutter/material.dart';

class ProfileDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("ADWAID RN"),
            accountEmail: Text("adwaid@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/profile_pic.jpg'), // Change this to network image if needed
            ),
            decoration: BoxDecoration(color: Colors.black87),
          ),
          _buildListTile(Icons.person, 'My Profile', () {}),
          _buildListTile(Icons.event, 'Create Event', () {}),
          _buildListTile(Icons.calendar_today, 'Calendar', () {}),
          _buildListTile(Icons.star, 'Starred', () {}),
          _buildListTile(Icons.business, 'Vendor', () {}),
          _buildListTile(Icons.settings, 'Settings', () {}),
          _buildListTile(Icons.help, 'Helps & FAQs', () {}),
          _buildListTile(Icons.exit_to_app, 'Sign Out', () {
            Navigator.pop(context);
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
}

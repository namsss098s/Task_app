import 'package:final_exam/AuthScreen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.purpleAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.pink[50], // Background color
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            _buildListItem(
              title: "Account",
              onTap: () {
                // Handle Account tap
              },
            ),
            _buildListItem(
              title: "Notifications",
              onTap: () {
                // Handle Notifications tap
              },
            ),
            _buildListItem(
              title: "Help",
              onTap: () {
                // Handle Help tap
              },
            ),
            _buildListItem(
              title: "Storage and Data",
              onTap: () {
                // Handle Storage and Data tap
              },
            ),
            _buildListItem(
              title: "Invite a friend",
              onTap: () {
                // Handle Invite a friend tap
              },
            ),
            _buildListItem(
              title: "Logout",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Authscreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thackur/screens/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F66A8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildListTile(Icons.delete, 'Delete Account', () async {
                await _showDeleteConfirmationDialog();
              }),
              _buildDivider(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // White background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Smooth edges
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFF6F66A8), size: 28), // Theme-matching icon
              SizedBox(width: 10),
              Text(
                "Confirm Deletion",
                style: TextStyle(
                  color: Color(0xFF6F66A8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF6F66A8), // Subtle cancel button
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteUserAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF6F66A8), // Theme color for button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUserAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      String userId = user.uid;

      // Delete the user's document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete the user from Firebase Authentication
      await user.delete();

      // Sign out the user
      await _auth.signOut();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );

      // Navigate to the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      leading: Icon(
        icon,
        color: const Color(0xFF6F66A8), // Theme-matching color
        size: MediaQuery.of(context).size.width * 0.07,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.045,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          size: MediaQuery.of(context).size.width * 0.05),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.grey,
      thickness: 1,
      height: 2,
    );
  }
}

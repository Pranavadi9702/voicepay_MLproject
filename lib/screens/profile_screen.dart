import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:thackur/screens/about_us.dart';
import 'package:thackur/screens/faqs.dart';
import 'package:thackur/screens/privacy_policy.dart';
import 'package:thackur/screens/settings.dart';
import 'package:thackur/screens/terms_conditions.dart';
import 'login_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String? username;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        if (userDoc.exists) {
          username = userDoc['name'] ??
              user.displayName ??
              user.email?.split('@')[0] ??
              "User";
          profileImage = userDoc['profileImage'] ?? user.photoURL;
        } else {
          username = user.displayName ?? user.email?.split('@')[0] ?? "User";
          profileImage = user.photoURL;
        }
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing on tap outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(Icons.logout,
                  size: 50, color: Color(0xFF6F66A8)), // Logout icon
              const SizedBox(height: 10),
              const Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to log out?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly, // Center actions
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Cancel", style: TextStyle(color: Colors.black)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6F66A8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Log Out",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Gradient header with back button
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFF6F66A8),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(50),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage:
                          profileImage != null && profileImage!.isNotEmpty
                              ? NetworkImage(profileImage!)
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 10),
                  username == null
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          username!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileItem(Icons.info, "About Us", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutUsPage()),
                    );
                  }),

                  _buildProfileItem(Icons.help, "FAQs", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpSupportPage()),
                    );
                  }),

                  _buildProfileItem(Icons.list_alt_outlined, "Terms & Conditions", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TermsConditionsPage()),
                    );
                  }),

                  _buildProfileItem(Icons.privacy_tip, "Privacy Policy", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage()),
                    );
                  }),

                  _buildProfileItem(Icons.settings, "Settings", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  }),

                  const Spacer(), // Pushes the bottom section to the bottom

                  // Terms & Conditions Section
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TermsConditionsPage()),
                              );
                            },
                            child: const Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2E2E2E),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text("  |  ", style: TextStyle(fontSize: 10)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyPolicyPage()),
                              );
                            },
                            child: const Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2E2E2E),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "App Version: V.0.0.1",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Log Out button at bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                backgroundColor: Color(0xFF6F66A8).withOpacity(0.9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF6F66A8), size: 26),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

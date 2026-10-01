import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF6F66A8),
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: screenWidth * 0.8, // Adjust the width as needed
          padding: EdgeInsets.symmetric(
              vertical:
                  screenHeight * 0.2), // Adjust the vertical padding as needed
          child: const Text(
            'No notifications',
            textAlign: TextAlign.center, // Center the text horizontally
          ),
        ),
      ),
    );
  }
}

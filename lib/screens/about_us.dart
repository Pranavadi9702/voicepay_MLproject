import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  AboutUsPageState createState() => AboutUsPageState();
}

class AboutUsPageState extends State<AboutUsPage> {
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
          "About Us",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to VoicePay",
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "A revolutionary platform designed to make ticket reselling seamless, secure, and efficient. Whether you're a buyer looking for last-minute tickets or a seller hoping to find the right buyer, our app ensures a smooth experience for all users.",
              style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Our Mission"),
            _buildSectionText(
                "We aim to create a transparent and trustworthy marketplace for ticket reselling. With real-time bidding, secure verification, and a user-friendly interface, we empower users to buy and sell tickets with confidence."),
            const SizedBox(height: 20),
            _buildSectionTitle("Key Features"),
            _buildBulletPoint("Bidding System – Get the best price for your tickets through competitive bidding."),
            _buildBulletPoint("Secure Transactions – All tickets are verified via our admin panel to ensure authenticity."),
            _buildBulletPoint("User-Friendly Experience – Simple navigation and smooth UI for hassle-free buying and selling."),
            _buildBulletPoint("Fast & Reliable – Instant ticket listings, quick notifications, and seamless payments."),
            const SizedBox(height: 20),
            _buildSectionTitle("Why Choose Us?"),
            _buildSectionText(
                "Unlike other platforms, [Your App Name] prioritizes security and fairness. Our advanced verification system prevents fraud, ensuring that every ticket sold is genuine."),
            const SizedBox(height: 20),
            _buildSectionTitle("Join Our Community"),
            _buildSectionText(
                "Become a part of our growing community of ticket buyers and sellers. Download the app today and experience a smarter way to resell tickets!"),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: MediaQuery.sizeOf(context).width * 0.05,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: MediaQuery.sizeOf(context).width * 0.04,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 18, color: Colors.black54)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: MediaQuery.sizeOf(context).width * 0.04,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

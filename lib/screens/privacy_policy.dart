import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get screen size
    final double padding = size.width * 0.05; // Dynamic padding

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
          "Privacy Policy",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size.width * 0.05, // Dynamic font size
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero, // Removed extra padding
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("1. Introduction:", size),
              _buildSectionContent(
                  "At VoicePay, we prioritize your privacy. This Privacy Policy explains how we collect, use, and protect your personal information while using our services.",
                  size),
              _buildSectionTitle("2. Information We Collect:", size),
              _buildBulletPoint(
                  "Account Information: Name, email, phone number, and authentication details.",
                  size),
              _buildBulletPoint(
                  "Transaction Data: Payment history, transaction details, and linked financial accounts.",
                  size),
              _buildBulletPoint(
                  "Technical Data: IP address, device type, operating system, and app usage logs.",
                  size),
              _buildBulletPoint(
                  "Voice Authentication Data: Securely stored voice patterns for authentication purposes.",
                  size),
              _buildSectionTitle("3. How We Use Your Data:", size),
              _buildBulletPoint(
                  "Enable secure voice-based payments and transactions.", size),
              _buildBulletPoint(
                  "Ensure fraud prevention and security measures.", size),
              _buildBulletPoint(
                  "Improve VoicePay services and enhance user experience.",
                  size),
              _buildBulletPoint(
                  "Send transaction notifications and important updates.",
                  size),
              _buildBulletPoint(
                  "Comply with legal and regulatory requirements.", size),
              _buildSectionTitle("4. Data Sharing & Third Parties:", size),
              _buildBulletPoint(
                  "We do not sell or rent your personal data.", size),
              _buildBulletPoint(
                  "Financial Institutions: We share transaction data with banks and payment gateways as needed.",
                  size),
              _buildBulletPoint(
                  "Legal Compliance: Data may be disclosed if required by law or for fraud prevention.",
                  size),
              _buildSectionTitle("5. Security Measures:", size),
              _buildBulletPoint(
                  "End-to-end encryption protects transactions and user data.",
                  size),
              _buildBulletPoint(
                  "Voice authentication data is securely stored and encrypted.",
                  size),
              _buildBulletPoint(
                  "Regular security audits ensure protection against threats.",
                  size),
              _buildSectionTitle("6. Your Rights & Data Control:", size),
              _buildBulletPoint(
                  "Users can update account details within the app.", size),
              _buildBulletPoint(
                  "Request data deletion by contacting support@voicepay.com.",
                  size),
              _buildBulletPoint(
                  "Manage communication preferences from account settings.",
                  size),
              _buildSectionTitle("7. Cookies & Tracking Technologies:", size),
              _buildBulletPoint(
                  "We use cookies and analytics to improve user experience.",
                  size),
              _buildBulletPoint(
                  "Users can control cookie preferences through browser settings.",
                  size),
              _buildSectionTitle("8. Changes to This Policy:", size),
              _buildSectionContent(
                  "This Privacy Policy may be updated periodically. Users will be notified of significant changes via email or app notifications.",
                  size),
              _buildSectionContent(
                  "Last updated: March 15, 2025. For inquiries, contact support@voicepay.com.",
                  size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Size size) {
    return Padding(
      padding:
          EdgeInsets.only(top: size.height * 0.02, bottom: size.height * 0.01),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.05, // Dynamic font size
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content, Size size) {
    return Text(
      content,
      style: TextStyle(
        color: Colors.black,
        fontSize: size.width * 0.04, // Dynamic font size
      ),
    );
  }

  Widget _buildBulletPoint(String text, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: size.height * 0.005), // Dynamic spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * 0.04)), // Dynamic bullet point size
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * 0.04), // Dynamic font size
            ),
          ),
        ],
      ),
    );
  }
}

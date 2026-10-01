import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
          "Terms & Conditions",
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
                  "Welcome to VoicePay, a secure and seamless voice-based payment platform. By using our services, you agree to the following Terms & Conditions.",
                  size),
              _buildSectionTitle("2. Account Registration:", size),
              _buildBulletPoint(
                  "Users must provide accurate personal and financial details to access VoicePay services.",
                  size),
              _buildBulletPoint(
                  "Each user is allowed only one account; multiple accounts may lead to suspension.",
                  size),
              _buildBulletPoint(
                  "Users must be at least 18 years old to use the platform.",
                  size),
              _buildSectionTitle("3. Transactions & Payments:", size),
              _buildBulletPoint(
                  "All transactions are processed securely using encrypted voice authentication.",
                  size),
              _buildBulletPoint(
                  "Users are responsible for verifying payment details before confirming transactions.",
                  size),
              _buildBulletPoint(
                  "Refunds and dispute resolutions are subject to the policies of the financial institution handling the transaction.",
                  size),
              _buildSectionTitle("4. Security & Fraud Prevention:", size),
              _buildBulletPoint(
                  "VoicePay employs advanced encryption and AI-driven fraud detection to ensure transaction security.",
                  size),
              _buildBulletPoint(
                  "Users must not share or misuse their voice authentication to prevent unauthorized access.",
                  size),
              _buildBulletPoint(
                  "Any fraudulent activity will result in account suspension and possible legal action.",
                  size),
              _buildSectionTitle("5. Fees & Charges:", size),
              _buildBulletPoint(
                  "Certain transactions may be subject to processing fees, which will be communicated before confirmation.",
                  size),
              _buildBulletPoint(
                  "VoicePay is not responsible for additional fees imposed by third-party banks or payment processors.",
                  size),
              _buildSectionTitle("6. Liability Disclaimer:", size),
              _buildBulletPoint(
                  "VoicePay is not liable for transaction failures caused by network issues or banking system errors.",
                  size),
              _buildBulletPoint(
                  "Users are responsible for ensuring the accuracy of payment details before authorizing transactions.",
                  size),
              _buildSectionTitle("7. Account Suspension & Termination:", size),
              _buildBulletPoint(
                  "VoicePay reserves the right to suspend or terminate accounts involved in fraudulent activities.",
                  size),
              _buildBulletPoint(
                  "Users can request account deletion by contacting customer support.",
                  size),
              _buildSectionTitle("8. Updates to Terms & Conditions:", size),
              _buildSectionContent(
                  "These terms may be updated periodically. Users will be notified of significant changes.",
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

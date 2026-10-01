import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  HelpSupportPageState createState() => HelpSupportPageState();
}

class HelpSupportPageState extends State<HelpSupportPage> {
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
          "Help & Support",
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
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFAQTile(
                  "Account & Access",
                  [
                    {
                      "question": "How do I create an account?",
                      "answer":
                          "You can sign up using your phone number and verify it using voice authentication."
                    },
                    {
                      "question": "How does VoicePay verify my identity?",
                      "answer":
                          "We use AI-powered voice recognition to ensure secure access."
                    },
                    {
                      "question": "Can I reset my voice authentication?",
                      "answer":
                          "Yes, go to 'Settings' > 'Voice Recognition' and follow the reset process."
                    }
                  ],
                  screenWidth),
              _buildFAQTile(
                  "Security & Authentication",
                  [
                    {
                      "question": "How secure is VoicePay?",
                      "answer":
                          "We use advanced encryption and AI-based fraud detection to protect your transactions."
                    },
                    {
                      "question":
                          "Can someone else use my voice to access my account?",
                      "answer":
                          "No, VoicePay’s AI detects unique voice patterns, preventing unauthorized access."
                    },
                    {
                      "question":
                          "What happens if my voice changes due to illness?",
                      "answer":
                          "You can reconfigure your voice authentication by verifying your identity."
                    }
                  ],
                  screenWidth),
              _buildFAQTile(
                  "Transactions & Payments",
                  [
                    {
                      "question": "How do I make a payment using VoicePay?",
                      "answer":
                          "Simply authenticate with your voice and approve transactions through the app."
                    },
                    {
                      "question": "Can I set spending limits?",
                      "answer":
                          "Yes, you can customize limits in the ‘Security Settings’ section."
                    },
                    {
                      "question": "What if a transaction is unauthorized?",
                      "answer":
                          "Our fraud detection system alerts you instantly. You can dispute transactions via the app."
                    }
                  ],
                  screenWidth),
              _buildFAQTile(
                  "Integration & Support",
                  [
                    {
                      "question": "Which banks and services support VoicePay?",
                      "answer":
                          "VoicePay integrates with leading banks and financial platforms. Check the app for a full list."
                    },
                    {
                      "question": "Can I use VoicePay for online shopping?",
                      "answer":
                          "Yes, VoicePay supports payments on partnered websites and apps."
                    },
                    {
                      "question": "How do I contact support?",
                      "answer":
                          "Visit the 'Help & Support' section in the app or email us at support@voicepay.com."
                    }
                  ],
                  screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(
      String title, List<Map<String, String>> faqs, double screenWidth) {
    return Column(
      children: faqs.map((faq) {
        return Card(
          color: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              title: Text(
                faq["question"]!,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.045,
                ),
              ),
              iconColor: const Color(0xFF2E2E2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Text(
                    faq["answer"]!,
                    style: TextStyle(
                        color: Colors.black87, fontSize: screenWidth * 0.04),
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

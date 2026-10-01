import 'package:flutter/material.dart';
import 'payment_details_screen.dart';

class PayToUpiPage extends StatefulWidget {
  const PayToUpiPage({super.key});

  @override
  State<PayToUpiPage> createState() => _PayToUpiPageState();
}

class _PayToUpiPageState extends State<PayToUpiPage> {
  final _upiController = TextEditingController();

  // Navigate to PaymentDetailsScreen
  void proceedToPayment() {
    final upiId = _upiController.text.trim();

    if (upiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a UPI ID.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsScreen(
          paymentDetails: {
            "name": "Unknown Name", // Placeholder since no name is fetched
            "upi_id": upiId,
            "amount": "0.00", // Default amount, editable on the next screen
            "currency": "INR",
          },
          upiId: upiId,
          amount: '',
          phoneNumber: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Pay To UPI ID",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF6F66A8),
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Ensures tap is detected anywhere
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // Unfocus the keyboard
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align content from the top
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              const Text(
                "Enter UPI ID",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),

              // UPI ID Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _upiController,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Enter UPI ID",
                    prefixIcon: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.purple),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Proceed to Payment Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    backgroundColor: const Color(0xFF6F66A8), // Premium purple
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Proceed to Payment",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

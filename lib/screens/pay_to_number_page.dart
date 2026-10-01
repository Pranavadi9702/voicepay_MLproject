import 'package:flutter/material.dart';
import 'package:thackur/screens/payment_details_screen.dart';

class PayToNumberPage extends StatefulWidget {
  const PayToNumberPage({super.key});

  @override
  State<PayToNumberPage> createState() => _PayToNumberPageState();
}

class _PayToNumberPageState extends State<PayToNumberPage> {
  final TextEditingController phoneController = TextEditingController();

  // Function to validate phone number
  bool _isValidPhoneNumber(String phoneNumber) {
    final RegExp phoneRegExp =
        RegExp(r'^[6-9][0-9]{9}$'); // Indian numbers without +91
    return phoneRegExp.hasMatch(phoneNumber);
  }

  // Navigate to Payment Details Screen
  void _proceedToPaymentDetails() {
    final String phoneNumber = phoneController.text.trim();

    if (!_isValidPhoneNumber(phoneNumber)) {
      _showError("Please enter a valid 10-digit phone number.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsScreen(
          phoneNumber: "+91 $phoneNumber",
          amount: "0.00",
          paymentDetails: {
            "upi_id": "$phoneNumber@upi",
            "name": "+91 $phoneNumber",
            "amount": "0.00",
            "currency": "INR",
          },
          upiId: "$phoneNumber@upi",
        ),
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        backgroundColor: Colors.white, // Matches your preference for dialogs
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 28), // Error icon
            const SizedBox(width: 8),
            const Text(
              "Error",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Red accent for error theme
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text("OK"),
          ),
        ],
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
          "Pay To Number",
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
          padding: const EdgeInsets.all(
              16.0), // Increased padding for better spacing
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Ensures full width
            children: [
              // Title
              const Text(
                "Enter Your Phone Number",
                style: TextStyle(
                  fontSize: 20, // Adjusted font size
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E), // Updated color to match the theme
                ),
                textAlign: TextAlign.left, // Aligned to the left
              ),

              const SizedBox(height: 16), // Adjusted spacing

              // Phone Number Input
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10, // Maximum 10 digits for Indian phone numbers
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  labelStyle: const TextStyle(
                    color: Color(0xFF2E2E2E), // Updated label color
                  ),
                  prefixText: "+91 ",
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: Color(0xFF2E2E2E), // Updated icon color
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16), // Increased border radius
                  ),
                  filled: true,
                  fillColor:
                      Colors.grey[200], // Light background for better contrast
                  counterText: "", // Hides the counter below
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF2E2E2E), // Updated border color
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 24), // Adjusted spacing

              // Proceed to Payment Button
              ElevatedButton.icon(
                onPressed: _proceedToPaymentDetails,
                label: const Text(
                  "Proceed to Payment",
                  style: TextStyle(fontSize: 18), // Adjusted font size
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF6F66A8), // Maintained button color
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size(double.infinity, 60), // Adjusted button size
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16), // Increased border radius
                  ),
                  elevation:
                      6, // Increased elevation for a better shadow effect
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

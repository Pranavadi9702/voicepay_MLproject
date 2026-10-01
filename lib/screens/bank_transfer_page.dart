import 'package:flutter/material.dart';
import 'payment_details_screen.dart';

class BankTransferPage extends StatefulWidget {
  const BankTransferPage({super.key});

  @override
  State<BankTransferPage> createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<BankTransferPage> {
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool _isValidInput() {
    if (accountNumberController.text.trim().isEmpty ||
        ifscController.text.trim().isEmpty ||
        accountHolderNameController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty) {
      _showError("All fields are required.");
      return false;
    }

    final double? amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError("Please enter a valid amount.");
      return false;
    }

    return true;
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _proceedToPaymentDetails() {
    if (_isValidInput()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentDetailsScreen(
            paymentDetails: {
              "name": accountHolderNameController.text.trim(),
              "upi_id":
                  "${accountNumberController.text.trim()} (IFSC: ${ifscController.text.trim()})",
              "amount": amountController.text.trim(),
            },
            phoneNumber: "N/A",
            amount: amountController.text.trim(),
            upiId: "N/A",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white, // Background color
      appBar: AppBar(
        title: Text(
          "Bank Transfer",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text color for contrast
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white), // White icon color
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF6F66A8), // Dark background color
        elevation: 0, // Remove elevation for a flat design
        shadowColor: Colors.transparent, // Remove shadow for a flat design
        centerTitle: true, // Align title to center
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Ensures tap is detected anywhere
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // Unfocus the keyboard
        },
        child: Container(
          decoration: const BoxDecoration(),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align content to the top
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white, // Maintains a clean UI inside the card
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          "Enter Payment Details",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2E2E),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 16),

                        // Account Holder Name
                        TextField(
                          controller: accountHolderNameController,
                          decoration: InputDecoration(
                            labelText: "Account Holder Name",
                            prefixIcon: const Icon(Icons.person,
                                color: Color(0xFF6F66A8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Account Number
                        TextField(
                          controller: accountNumberController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Account Number",
                            prefixIcon: const Icon(Icons.account_balance,
                                color: Color(0xFF6F66A8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // IFSC Code
                        TextField(
                          controller: ifscController,
                          decoration: InputDecoration(
                            labelText: "IFSC Code",
                            prefixIcon: const Icon(Icons.qr_code,
                                color: Color(0xFF6F66A8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Amount
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Enter Amount",
                            prefixIcon: const Icon(Icons.currency_rupee,
                                color: Color(0xFF6F66A8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Send Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _proceedToPaymentDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6F66A8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 6,
                            ),
                            child: const Text(
                              "Send Payment",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
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

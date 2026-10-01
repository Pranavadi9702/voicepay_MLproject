import 'package:flutter/material.dart';
import 'package:thackur/screens/voice_signature_payment.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final Map<String, String> paymentDetails;
  final String upiId;
  final String amount;
  final String phoneNumber;

  const PaymentDetailsScreen({
    super.key,
    required this.paymentDetails,
    required this.upiId,
    required this.amount,
    required this.phoneNumber,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.amount);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Confirm Payment",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card with payment summary
              Card(
                color: Colors.white, // Changed from dark to a lighter shade
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6, // Added slight elevation for depth
                shadowColor: Colors.grey.withOpacity(0.2), // Soft shadow
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Paying To",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.paymentDetails["name"] ?? "Unknown",
                        style: const TextStyle(
                          color: Color(0xFF2E2E2E),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.paymentDetails["upi_id"] ?? "Not Available",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Phone Number: ${widget.phoneNumber}",
                        style: const TextStyle(
                            color: Color(0xFF2E2E2E), fontSize: 14),
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text(
                        "Enter Amount",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            color: Color(0xFF2E2E2E), fontSize: 18),
                        decoration: InputDecoration(
                          prefixText: "₹ ",
                          prefixStyle: const TextStyle(
                              color: Color(0xFF2E2E2E), fontSize: 18),
                          filled: true,
                          fillColor:
                              Colors.grey[200], // Light background for input
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Payment button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Update the amount in payment details map
                    widget.paymentDetails["amount"] = amountController.text;

                    // Navigate to VoiceSignaturePayment with all required parameters
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VoiceSignaturePayment(
                          paymentDetails: widget.paymentDetails,
                          upiId: widget.upiId,
                          amount: amountController.text,
                          phoneNumber: widget.phoneNumber,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6F66A8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4, // Added subtle elevation for button depth
                  ),
                  child: const Text(
                    "Proceed to Pay",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

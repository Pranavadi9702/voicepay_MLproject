import 'package:flutter/material.dart';

class PayToSelfPage extends StatefulWidget {
  const PayToSelfPage({super.key});

  @override
  State<PayToSelfPage> createState() => _PayToSelfPageState();
}

class _PayToSelfPageState extends State<PayToSelfPage> {
  double walletBalance = 0.0; // Wallet balance state
  List<String> transactionHistory = []; // Transaction history

  // Function to add money
  void _addMoney(double amount) {
    setState(() {
      walletBalance += amount;
      transactionHistory.insert(0, "+ ₹$amount added to wallet");
    });
  }

  // Function to remove money
  void _removeMoney(double amount) {
    if (amount <= walletBalance) {
      setState(() {
        walletBalance -= amount;
        transactionHistory.insert(0, "- ₹$amount removed from wallet");
      });
    } else {
      _showError("Insufficient balance");
    }
  }

  // Error Dialog
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

  // Dialog to prompt user for amount
  void _showAmountDialog(bool isAdding) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)), // Rounded corners
        title: Text(
          isAdding ? "Add Money" : "Withdraw",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E), // Dark color for better readability
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(thickness: 1, height: 10, color: Colors.grey),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: "Enter Amount",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                isAdding ? _addMoney(amount) : _removeMoney(amount);
              } else {
                _showError("Invalid amount");
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B), // Teal for confirmation
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
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
          "Pay To Self",
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
       // Dark theme for modern look
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Wallet Card
            // Wallet Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF206A5D), // Deep Greenish Teal
                    Color(0xFF121212), // Almost Black for Contrast
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Wallet Balance",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "₹ ${walletBalance.toStringAsFixed(2)}", // Dynamic balance
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showAmountDialog(true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    backgroundColor: const Color(0xFF00897B), // Teal
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 22, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Add Money",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAmountDialog(false),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    backgroundColor: const Color(0xFFF57C00), // Orange
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.remove, size: 22, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Withdraw",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Transaction History
            Expanded(
              child: ListView.builder(
                itemCount: transactionHistory.length,
                itemBuilder: (context, index) {
                  final transaction = transactionHistory[index];
                  return ListTile(
                    title: Text(
                      transaction,
                      style: TextStyle(
                        color: transaction.startsWith('+')
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

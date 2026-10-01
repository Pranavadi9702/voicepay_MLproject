import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key, required String userId});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTransactions = prefs.getString('transactions');

    if (storedTransactions != null) {
      setState(() {
        transactions =
            List<Map<String, dynamic>>.from(jsonDecode(storedTransactions));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Transaction History",
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
      body: transactions.isEmpty
          ? const Center(child: Text("No transactions found."))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  elevation: 4, // Shadow for depth
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(16.0), // Padding inside the card
                    title: Text(
                      "UPI ID: ${transaction['upi_id']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Amount: ₹${transaction['amount']}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4), // Spacing between lines
                        Text(
                          "Date: ${transaction['date']}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4), // Spacing between lines
                        Text(
                          "Status: ${transaction['status']}",
                          style: TextStyle(
                            fontSize: 14,
                            color: transaction['status'] == 'Success'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

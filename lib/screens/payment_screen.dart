import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class PaymentScreen extends StatefulWidget {
  final Map<String, String> paymentDetails;

  const PaymentScreen({super.key, required this.paymentDetails});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  String _statusMessage = "Opening Razorpay checkout...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startPayment();
      }
    });
  }

  void _startPayment() {
    setState(() {
      _isLoading = true;
      _statusMessage = "Launching payment gateway...";
    });

    // Sanitize and parse amount safely
    String rawAmount = widget.paymentDetails["amount"] ?? "1.00";
    String sanitized = rawAmount.replaceAll(RegExp(r'[^0-9.]'), '');
    double parsedAmount = double.tryParse(sanitized) ?? 1.00;
    
    // Razorpay minimum amount is 1 INR (100 paise)
    if (parsedAmount < 1.00) {
      parsedAmount = 1.00;
    }

    int amountInPaise = (parsedAmount * 100).round();

    String name = widget.paymentDetails["name"] ?? "VoicePay User";
    if (name.trim().isEmpty) name = "VoicePay User";

    String upiId = widget.paymentDetails["upi_id"] ?? "merchant@upi";
    if (upiId.trim().isEmpty) upiId = "voicepay@upi";

    var options = {
      'key': const String.fromEnvironment('RAZORPAY_KEY', defaultValue: 'YOUR_RAZORPAY_KEY_HERE'),
      'amount': amountInPaise,
      'currency': widget.paymentDetails["currency"] ?? "INR",
      'name': 'VoicePay',
      'description': 'Payment of ₹${parsedAmount.toStringAsFixed(2)} to $upiId',
      'prefill': {
        'contact': '9876543210',
        'email': 'user@voicepay.com',
      },
      'theme': {
        'color': '#6F66A8',
      },
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
      'send_sms_hash': true,
      'external': {
        'wallets': ['paytm'],
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay open error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Error opening payment gateway: $e";
        });
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _saveTransaction({
      'upi_id': widget.paymentDetails["upi_id"] ?? "Unknown",
      'amount': widget.paymentDetails["amount"] ?? "1.00",
      'date': DateTime.now().toString(),
      'status': 'Success',
      'payment_id': response.paymentId ?? "N/A",
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Payment Successful! Payment ID: ${response.paymentId}"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Razorpay Failure: Code=${response.code}, Message=${response.message}");
    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Payment Failed: ${response.message ?? 'Cancelled or Failed'}\n(Error Code: ${response.code})";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Payment Failed: ${response.message ?? 'Unknown error'}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _saveTransaction(Map<String, dynamic> transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedTransactions = prefs.getString('transactions') ?? '[]';

      List<Map<String, dynamic>> transactions =
          List<Map<String, dynamic>>.from(jsonDecode(storedTransactions));

      transactions.add(transaction);

      await prefs.setString('transactions', jsonEncode(transactions));
    } catch (e) {
      debugPrint("Error saving transaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Razorpay Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6F66A8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  color: Color(0xFF6F66A8),
                )
              else
                const Icon(
                  Icons.payment_rounded,
                  size: 64,
                  color: Color(0xFF6F66A8),
                ),
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              if (!_isLoading) ...[
                ElevatedButton.icon(
                  onPressed: _startPayment,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry Payment"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6F66A8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Go Back"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
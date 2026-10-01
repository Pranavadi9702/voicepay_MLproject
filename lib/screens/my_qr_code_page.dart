import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyQrCodePage extends StatefulWidget {
  const MyQrCodePage({super.key, required String userName, required String upiId});

  @override
  State<MyQrCodePage> createState() => _MyQrCodePageState();
}

class _MyQrCodePageState extends State<MyQrCodePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(clientId: '162956421112.apps.googleusercontent.com');
  String userName = "User";
  String upiId = "default@upi";

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      setState(() {
        userName = googleUser.displayName ?? "Unknown User";
        upiId = "${googleUser.email.split('@').first}@upi"; // Dynamic UPI ID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String qrData =
        "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(userName)}&mc=0000&tid=TXN${DateTime.now().millisecondsSinceEpoch}&tr=ORDER123&tn=Payment%20to%20$userName&am=0&cu=INR";

    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My QR Code",
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            Text(
              "Scan to Pay $userName",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              upiId,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

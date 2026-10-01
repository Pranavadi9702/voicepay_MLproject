import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thackur/screens/home_screen.dart';
import 'package:thackur/screens/payment_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class VoiceSignaturePayment extends StatefulWidget {
  final Map<String, String> paymentDetails;
  final String upiId;
  final String amount;
  final String phoneNumber;

  const VoiceSignaturePayment({
    super.key,
    required this.paymentDetails,
    required this.upiId,
    required this.amount,
    required this.phoneNumber,
  });

  @override
  VoiceSignaturePaymentState createState() => VoiceSignaturePaymentState();
}

class VoiceSignaturePaymentState extends State<VoiceSignaturePayment> {
  String username = "";
  bool isRecording = false;
  String resultMessage = " ";
  final AudioRecorder recorder = AudioRecorder();
  bool showResultMessage = true;

  @override
  void initState() {
    super.initState();
    fetchUsername();
    // You can use the parameters like this:
    print("Payment to: ${widget.upiId}");
    print("Amount: ${widget.amount}");
    print("Phone Number: ${widget.phoneNumber}");
    print("Payment Details: ${widget.paymentDetails}");
    // etc.
  }

  void fetchUsername() {
    User? user = FirebaseAuth.instance.currentUser;
    String derived = "Unknown";
    if (user != null) {
      final email = user.email;
      if (email != null && email.contains('@')) {
        derived = email.split('@')[0];
      } else if (user.displayName != null && user.displayName!.isNotEmpty) {
        // Fallback for social login with no email
        derived = user.displayName!.replaceAll(' ', '').toLowerCase();
      }
    }
    setState(() {
      username = derived;
    });
    print("🔑 Voice signature username: $username");
  }

  List<String> get _backendUrls => [
    "http://127.0.0.1:5002",
    "http://10.120.103.153:5002",
    "http://10.0.2.2:5002",
  ];

  Future<void> recordVoiceSignature() async {
    setState(() {
      resultMessage =
          "🎤 Tap the button to start verifying your unique voice signature.";
    });

    String? audioFilePath = await recordAudio();
    if (audioFilePath == null) {
      setState(() => resultMessage = "❌ Recording failed.");
      return;
    }

    try {
      setState(() {
        resultMessage = "📤 Uploading voice signature...";
      });

      List<int> audioBytes = [];
      if (kIsWeb) {
        if (audioFilePath.startsWith('blob:') || audioFilePath.startsWith('http')) {
          final res = await http.get(Uri.parse(audioFilePath));
          audioBytes = res.bodyBytes;
        } else {
          audioBytes = List<int>.filled(2048, 0);
        }
      } else {
        File file = File(audioFilePath);
        if (await file.exists()) {
          audioBytes = await file.readAsBytes();
        }
      }

      http.StreamedResponse? response;
      for (String base in _backendUrls) {
        try {
          var request = http.MultipartRequest(
            "POST",
            Uri.parse("$base/verify_voice_signature"),
          );
          request.fields["username"] = username;
          if (audioBytes.isNotEmpty) {
            request.files.add(http.MultipartFile.fromBytes("audio", audioBytes, filename: "audio.wav"));
          } else {
            request.files.add(await http.MultipartFile.fromPath("audio", audioFilePath));
          }
          response = await request.send().timeout(const Duration(seconds: 30));
          break;
        } catch (e) {
          print("Failed to reach $base: $e");
        }
      }

      if (response == null) {
        throw Exception("Could not connect to backend at ${_backendUrls.join(', ')}. Please ensure Python server is running and re-run 'flutter run'.");
      }

      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (response.statusCode == 200 || data['status'] == 'success' || data['result'] == 'Success') {
        setState(() {
          resultMessage = "✅ Voice signature verified successfully!";
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PaymentScreen(paymentDetails: widget.paymentDetails),
              ),
            );
          }
        });
      } else {
        setState(() {
          resultMessage =
              "❌ Failed to verify voice signature: ${data['error'] ?? data['message'] ?? 'Unknown error.'}";
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = "❌ Error uploading voice signature: $e";
      });
    }
  }

  Future<String?> recordAudio() async {
    try {
      if (await recorder.hasPermission()) {
        String filePath = '';
        if (!kIsWeb) {
          Directory tempDir = await getTemporaryDirectory();
          filePath = '${tempDir.path}/audio.wav';
        }

        setState(() {
          resultMessage = "🎤 Recording in progress...";
          isRecording = true;
        });

        await recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: filePath,
        );

        await Future.delayed(const Duration(seconds: 4));

        final recordedPath = await recorder.stop();
        setState(() {
          isRecording = false;
          resultMessage = "✅ Recording complete.";
        });

        return recordedPath ?? (kIsWeb ? 'web_audio' : filePath);
      } else {
        setState(() {
          resultMessage = "❌ No microphone permission!";
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = "❌ Recording error: $e";
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Signature Payment Gateway"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: recordVoiceSignature,
                child: const Text("🔊 Verify your Voice Signature"),
              ),
              if (showResultMessage) ...[
                const SizedBox(height: 20),
                Text(
                  resultMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

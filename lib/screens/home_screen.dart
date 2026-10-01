import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thackur/screens/bank_transfer_page.dart';
import 'dart:convert';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thackur/screens/my_qr_code_page.dart';
import 'package:thackur/screens/notifications_page.dart';
import 'package:thackur/screens/pay_to_contacts_page.dart';
import 'package:thackur/screens/pay_to_number_page.dart';
import 'package:thackur/screens/pay_to_self_page.dart';
import 'package:thackur/screens/pay_to_upi_page.dart';
import 'package:thackur/screens/profile_screen.dart';
import 'package:thackur/screens/qr_scan_page.dart';
import 'package:thackur/screens/transaction_history_page.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  String username = "User";
  List<Map<String, dynamic>> recentContacts = [];
  bool isLoading = true;
  bool isMicrophoneActive = false;
  final AudioRecorder recorder = AudioRecorder();
  String transcribedText = "";
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    fetchUsername();
    _loadRecentContacts();
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  void navigateToIntentPage(String iconCode) {
    print("Received icon_code: $iconCode");

    switch (iconCode) {
      case "1001":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const QrScanPage()));
        break;
      case "1002":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PayToContactsPage()));
        break;
      case "1003":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PayToUpiPage()));
        break;
      case "1004":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const TransactionHistoryPage(userId: '')));
        break;
      case "1005":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const MyQrCodePage(userName: '', upiId: '')));
        break;
      case "1006":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PayToSelfPage()));
        break;
      case "1007":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PayToNumberPage()));
        break;
      case "1008":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const BankTransferPage()));
        break;
      default:
        // Optionally handle unknown intents
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown intent detected')),
        );
    }
  }

  void fetchUsername() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          username = user.displayName!;
        } else if (user.email != null) {
          username = user.email!.split('@')[0];
        } else {
          username = "User";
        }
      });
    }
  }

  Future<void> _loadRecentContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTransactions = prefs.getString('transactions');

    if (storedTransactions != null) {
      List<Map<String, dynamic>> transactions =
          List<Map<String, dynamic>>.from(jsonDecode(storedTransactions));

      // Extract unique recent contacts
      Set<String> uniqueContacts = {};
      List<Map<String, dynamic>> recentContactsList = [];

      for (var transaction in transactions) {
        if (!uniqueContacts.contains(transaction['upi_id'])) {
          uniqueContacts.add(transaction['upi_id']);
          recentContactsList.add(transaction);
        }
      }

      setState(() {
        recentContacts =
            recentContactsList.take(10).toList(); // Limit to 10 recent contacts
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> startRecording() async {
    try {
      if (await recorder.hasPermission()) {
        String filePath = '';
        if (!kIsWeb) {
          Directory tempDir = await getTemporaryDirectory();
          filePath = '${tempDir.path}/audio.wav';
        }

        await recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: filePath,
        );

        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await recorder.stop();
      if (path != null) {
        setState(() {
          isRecording = false;
          transcribedText = "Processing audio..."; // Show loading state
        });

        List<String> backendUrls = [
          'http://127.0.0.1:5002',
          'http://10.120.103.153:5002',
          'http://10.0.2.2:5002',
        ];

        List<int> audioBytes = [];
        if (kIsWeb) {
          if (path.startsWith('blob:') || path.startsWith('http')) {
            final res = await http.get(Uri.parse(path));
            audioBytes = res.bodyBytes;
          } else {
            audioBytes = List<int>.filled(2048, 0);
          }
        } else {
          File file = File(path);
          if (await file.exists()) {
            audioBytes = await file.readAsBytes();
          }
        }

        http.StreamedResponse? response;
        for (String base in backendUrls) {
          try {
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('$base/process_audio'),
            );
            if (audioBytes.isNotEmpty) {
              request.files.add(http.MultipartFile.fromBytes('audio', audioBytes, filename: 'audio.wav'));
            } else {
              request.files.add(await http.MultipartFile.fromPath('audio', path));
            }
            response = await request.send().timeout(const Duration(seconds: 30));
            break;
          } catch (e) {
            print("Failed to reach $base: $e");
          }
        }

        if (response == null) {
          throw Exception("Could not connect to voice backend server.");
        }

        var responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);

        if (response.statusCode == 200) {
          setState(() {
            transcribedText = data['text'] ?? "No text recognized";
          });

          // Check for icon_code and navigate
          String? iconCode = data['icon_code'];
          if (iconCode != null) {
            navigateToIntentPage(iconCode); // Redirect to appropriate page
          }
        } else if (response.statusCode == 403) {
          setState(() {
            transcribedText = "🚨 Deepfake detected! Please try again.";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deepfake detected! Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (response.statusCode == 503) {
          setState(() {
            transcribedText =
                "❌ Server error: Models not loaded. Please try again later.";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Server error: Models not loaded. Please try again later.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          setState(() {
            transcribedText =
                "❌ Error: ${data['error'] ?? 'Failed to process audio'}";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Failed to process audio'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        transcribedText = "❌ Error: Failed to process audio. Please try again.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6F66A8),
        title: Text(
          "Hi, $username",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First row of buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSquareButton(context, Icons.qr_code_scanner,
                            "QR\nScan", const QrScanPage(), "1001"),
                        _buildSquareButton(
                            context,
                            Icons.contacts,
                            "Pay To\nContacts",
                            const PayToContactsPage(),
                            "1002"),
                        _buildSquareButton(context, Icons.payment,
                            "Pay To\nUPI ID", const PayToUpiPage(), "1003"),
                        _buildSquareButton(
                            context,
                            Icons.history,
                            "Transaction\nHistory",
                            const TransactionHistoryPage(userId: ''),
                            "1004"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Second row of additional buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSquareButton(
                            context,
                            Icons.qr_code,
                            "My QR\nCode",
                            const MyQrCodePage(userName: '', upiId: ''),
                            "1005"),
                        _buildSquareButton(
                            context,
                            Icons.account_balance_wallet,
                            "Pay To\nSelf",
                            const PayToSelfPage(),
                            "1006"),
                        _buildSquareButton(context, Icons.phone,
                            "Pay To\nNumber", const PayToNumberPage(), "1007"),
                        _buildSquareButton(context, Icons.account_balance,
                            "Bank\nTransfer", const BankTransferPage(), "1008"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Recent Contacts
                    const Text(
                      "Recent Contacts",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E)),
                    ),
                    const SizedBox(height: 10),

// Fetch Recent Contacts
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : recentContacts.isEmpty
                              ? const Center(child: Text("No recent contacts"))
                              : SizedBox(
                                  height: 100,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: recentContacts.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 15),
                                    itemBuilder: (context, index) {
                                      final contact = recentContacts[index];

                                      // Ensure the contact has a 'name' field
                                      if (contact['name'] == null ||
                                          contact['name'] is! String) {
                                        return const Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                                  Color(0xFF6F66A8),
                                              child: Text(
                                                "?",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            SizedBox(
                                              width: 70,
                                              child: Text(
                                                "Unknown",
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      return Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor:
                                                const Color(0xFF6F66A8),
                                            child: Text(
                                              contact['name'][0].toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          SizedBox(
                                            width: 70,
                                            child: Text(
                                              contact['name'],
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Microphone Icon at Bottom Right with Transcribed Text
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (transcribedText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      transcribedText,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                FloatingActionButton(
                  onPressed: () async {
                    setState(() {
                      isMicrophoneActive = !isMicrophoneActive;
                    });

                    if (isMicrophoneActive) {
                      await startRecording();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎤 Recording started'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      await stopRecording();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎤 Recording stopped'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  backgroundColor:
                      isMicrophoneActive ? Colors.red : Color(0xFF6F66A8),
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton(BuildContext context, IconData icon, String label,
      Widget page, String id) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => page));
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(20),
              minimumSize: const Size(70, 70),
              backgroundColor: Colors.grey[200],
            ),
            child: Icon(icon, size: 30, color: Color(0xFF6F66A8)),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 70,
          child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),
        ),
        Text(id,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

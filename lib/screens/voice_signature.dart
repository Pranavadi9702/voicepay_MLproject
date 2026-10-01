import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thackur/screens/home_screen.dart';
import 'package:thackur/screens/login_page.dart';

class VoiceSignatureScreen extends StatefulWidget {
  const VoiceSignatureScreen({super.key});

  @override
  VoiceSignatureScreenState createState() => VoiceSignatureScreenState();
}

class VoiceSignatureScreenState extends State<VoiceSignatureScreen> {
  String username = "";
  List<String> sentences = [];
  int currentSentenceIndex = 0;
  bool isRecording = false;
  String resultMessage =
      "Click on the button to start the voice training phase";
  final AudioRecorder recorder = AudioRecorder();
  bool trainingComplete = false;
  bool showGetSentencesButton = true; // Initially true to show the button
  bool showRecordButton = true;
  bool showResultMessage = true;
  bool showHomeButton = false;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  void fetchUsername() {
    User? user = FirebaseAuth.instance.currentUser;
    String derived = "Unknown";
    if (user != null) {
      final email = user.email;
      if (email != null && email.contains('@')) {
        derived = email.split('@')[0];
      } else if (user.displayName != null && user.displayName!.isNotEmpty) {
        derived = user.displayName!.replaceAll(' ', '').toLowerCase();
      }
    }
    setState(() {
      username = derived;
    });
    print("🔑 Voice signature username: $username");
  }

  void recordVoiceSignatureButton() {
    // Simulate voice signature creation
    setState(() {
      trainingComplete = true;
      resultMessage = "✅ Voice Signature Created Successfully!";
    });

    // Hide the button and message after 5 seconds, then navigate to home
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  List<String> get _backendUrls => [
    "http://127.0.0.1:5002",
    "http://10.120.103.153:5002",
    "http://10.0.2.2:5002",
  ];

  Future<void> fetchSentences() async {
    print("fetchSentences called with username: $username");
    if (username.isEmpty) {
      setState(() {
        resultMessage = "❌ Please enter a username!";
      });
      return;
    }

    http.Response? response;
    for (String base in _backendUrls) {
      try {
        response = await http
            .post(
              Uri.parse("$base/get_sentences"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"username": username}),
            )
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) break;
      } catch (e) {
        print("Failed to reach $base: $e");
      }
    }

    if (response != null && response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        sentences = List<String>.from(data["sentences"]);
        resultMessage = "📜 SUCCESS: ${sentences.length} sentences loaded!";
        currentSentenceIndex = 0;
        trainingComplete = false;
      });
    } else {
      setState(() {
        resultMessage =
            "❌ Failed to load sentences. Please ensure Python backend is running.";
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
          resultMessage = "✅ Recording complete. Uploading...";
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

  Future<void> verifySpeech() async {
    if (sentences.isEmpty || username.isEmpty) return;

    setState(() {
      resultMessage = "🎙 Say: \"${sentences[currentSentenceIndex]}\"";
    });

    String? audioFilePath = await recordAudio();
    if (audioFilePath == null) {
      setState(() => resultMessage = "❌ Recording failed.");
      return;
    }

    try {
      setState(() {
        resultMessage = "📤 Uploading audio...";
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
            Uri.parse("$base/verify_speech"),
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
        throw Exception("Server unreachable. Please make sure python app.py is running.");
      }

      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      String deepfakeResult = data["deepfake_result"] ?? "Unknown";
      String message = data["message"] ?? "Unknown response";

      if (response.statusCode == 403) {
        // Deepfake detected
        setState(() {
          resultMessage =
              "🚨 Deepfake detected! Restarting process.\n🛡️ Deepfake Check: $deepfakeResult\n";
        });
        await Future.delayed(const Duration(seconds: 3));
        fetchSentences();
        return;
      }

      if (response.statusCode == 401) {
        // Incorrect sentence
        setState(() {
          resultMessage =
              "❌ Incorrect. Say: \"${sentences[currentSentenceIndex]}\" again.\n";
        });
        return;
      }

      if (response.statusCode == 200) {
        if (data["training_complete"] == true) {
          setState(() {
            resultMessage = "✅ $message\n🎉 Training Complete!\n";
            trainingComplete = true;
          });
        } else {
          setState(() {
            resultMessage = "✅ $message\n🛡️ Deepfake Check: $deepfakeResult\n";
            currentSentenceIndex++;
          });
        }
      } else {
        setState(() {
          resultMessage = "❌ $message\n🛡️ Deepfake Check: $deepfakeResult\n";
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = "❌ Error verifying speech: $e";
      });
    }
  }

  Future<void> recordVoiceSignature() async {
    if (!trainingComplete) return;

    setState(() {
      resultMessage =
          "🎤 Tap the button to start recording your unique voice signature.";
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
            Uri.parse("$base/create_voice_signature"),
          );
          request.fields["username"] = username;
          if (audioBytes.isNotEmpty) {
            request.files.add(http.MultipartFile.fromBytes("audio", audioBytes, filename: "audio.wav"));
          } else {
            request.files.add(await http.MultipartFile.fromPath("audio", audioFilePath));
          }
          response = await request.send().timeout(const Duration(seconds: 35));
          break;
        } catch (e) {
          print("Failed to reach $base: $e");
        }
      }

      if (response == null) {
        throw Exception("Server unreachable. Please check backend connection.");
      }

      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        setState(() {
          resultMessage = "✅ Voice signature saved successfully!";
        });
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        });
      } else {
        setState(() {
          resultMessage = "❌ Failed to save voice signature: ${data['error']}";
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = "❌ Error uploading voice signature: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Signature Training"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                username.isNotEmpty
                    ? "👤 Username: $username"
                    : "Fetching username...",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Hide the button after clicking
            if (showGetSentencesButton)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    fetchSentences();
                    setState(() {
                      showGetSentencesButton = false; // Hide after clicking
                    });
                  },
                  child: const Text("📜 Get Sentences"),
                ),
              ),

            const SizedBox(height: 20),

            // Hide sentences and "Record & Verify" button when training is complete
            if (!trainingComplete && sentences.isNotEmpty) ...[
              Center(
                child: Text(
                  "Say: \"${sentences[currentSentenceIndex]}\"",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifySpeech,
                child:
                    Text(isRecording ? "⏳ Recording..." : "🎤 Record & Verify"),
              ),
            ],

            if (trainingComplete && showRecordButton) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: recordVoiceSignature,
                child: const Text("🔊 Record Voice Signature"),
              ),
            ],

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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _emailSent = false;
  String? _emailError;

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = "Email is required.");
      return;
    } else if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(email)) {
      setState(() => _emailError = "Enter a valid email.");
      return;
    }

    setState(() {
      _emailError = null;
      _isSubmitting = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) setState(() { _isSubmitting = false; _emailSent = true; });
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _emailError = e.code == 'user-not-found'
              ? 'No account found for this email.'
              : 'Failed to send reset email: ${e.message}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF6F66A8), // Background color
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100), // Space from the top

              // Heading outside the container
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Expanded container with conditional subheading
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center align the subheading
                      children: [
                        if (!_emailSent) ...[
                          const SizedBox(
                              height: 20), // Space from the top for subheading

                          const Text(
                            'Enter your email to reset your password',
                            textAlign: TextAlign.center, // Center the text
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                        _emailSent
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 80),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Email Sent!",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "We’ve sent a password reset link to your email.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Back to Login
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Back to Login",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email Field
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: "Email Address",
                                      hintText: "Enter your email",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      errorText: _emailError,
                                    ),
                                    onChanged: (_) {
                                      setState(() {
                                        _emailError = null;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Reset Password Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isSubmitting ? null : _submitEmail,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor: _isSubmitting
                                            ? Colors.grey
                                            : Color(0xFF6F66A8),
                                      ),
                                      child: _isSubmitting
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : const Text(
                                              "Reset Password",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Back to Login Button
                                  Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Navigate back to Login Page
                                      },
                                      child: const Text(
                                        "Back to Login",
                                        style: TextStyle(
                                          color: Color(0xFF6F66A8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

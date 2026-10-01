import 'package:thackur/screens/voice_signature.dart';

import 'signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'home_screen.dart'; // Import HomePage
import 'forget_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isPasswordVisible = false; // For toggling password visibility
  bool _isFormValid = false; // To enable/disable the Login button

  String? _emailError;
  String? _passwordError;

  // Method to validate the form
  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      // Email validation
      if (email.isEmpty) {
        _emailError = "Email is required.";
      } else if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(email)) {
        _emailError = "Enter a valid email.";
      } else {
        _emailError = null;
      }

      // Password validation
      if (password.isEmpty) {
        _passwordError = "Password is required.";
      } else if (password.length < 6) {
        _passwordError = "Password must be at least 6 characters.";
      } else {
        _passwordError = null;
      }

      // Enable the "Log In" button only if all fields are valid
      _isFormValid = _emailError == null && _passwordError == null;
    });
  }

  // Firebase login method
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Sign in with Firebase Auth
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Show login success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful')),
        );

        // Navigate to the HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase error
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Incorrect email or password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      } else {
        errorMessage = 'Login failed: ${e.message}';
      }

      // Show error popup message
      _showErrorDialog(errorMessage);
    }
  }

  // Google Sign-In method
  Future<void> _googleSignInMethod() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential from Google Authentication
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with Firebase
        await _auth.signInWithCredential(credential);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful')),
        );

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VoiceSignatureScreen()),
        );
      }
    } catch (e) {
      // Show Google Sign-In error popup
      _showErrorDialog('Google Sign-In failed. Please try again.');
    }
  }

  // Function to show a styled error message in a popup dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          backgroundColor:
              const Color(0xFF6F66A8), // Background color matching your theme
          title: const Text(
            'Error',
            style: TextStyle(
              color: Colors.black, // Title text color
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black, // Message text color
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color:
                      Color(0xFF6F66A8), // Matching theme color for the button
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns to the left
            children: [
              const SizedBox(height: 100), // Space from the top

              // "Log In" Heading
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Subheading
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Enter your credentials to access your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Expanded Container to fill remaining space
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20), // Inner padding
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align to the left
                      children: [
                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Your Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorText: _emailError, // Display email error
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible, // Toggle visibility
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            errorText: _passwordError, // Display password error
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 10),

                        // Forget Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forget password?',
                              style: TextStyle(
                                color: Color(0xFF6F66A8),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Log In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isFormValid ? _login : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFormValid
                                  ? Color(0xFF6F66A8)
                                  : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Already Have Account? Sign Up
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to Sign-Up page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: 'Sign up',
                                    style: TextStyle(
                                      color: Color(0xFF6F66A8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Divider with Text
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Or log in with',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Social Media Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google Button
                            GestureDetector(
                              onTap: _googleSignInMethod, // Call Google Sign-In
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                backgroundImage:
                                    AssetImage('assets/google.png'),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Facebook Button
                            GestureDetector(
                              onTap: () {
                                // Handle Facebook Log-In
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                backgroundImage:
                                    AssetImage('assets/facebook.png'),
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

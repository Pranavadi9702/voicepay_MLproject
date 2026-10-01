// home_screen.dart imported via voice_signature.dart indirectly
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'voice_signature.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCheckboxChecked = false;
  bool _isFormValid = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to validate the form
  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

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

      // Confirm Password validation
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = "Please confirm your password.";
      } else if (password != confirmPassword) {
        _confirmPasswordError = "Passwords do not match.";
      } else {
        _confirmPasswordError = null;
      }

      // Enable the "Create account" button only if all fields are valid and the checkbox is checked
      _isFormValid = _emailError == null &&
          _passwordError == null &&
          _confirmPasswordError == null &&
          _isCheckboxChecked;
    });
  }

  // Method to create an account using Firebase Authentication
  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Create user with Firebase
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Set up your voice signature.')),
        );
        // Navigate to voice signature setup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VoiceSignatureScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Sign up failed. Please try again.';
      if (e.code == 'email-already-in-use') msg = 'An account already exists for this email.';
      else if (e.code == 'weak-password') msg = 'Password is too weak (min 6 characters).';
      else if (e.code == 'invalid-email') msg = 'Invalid email address.';
      else msg = 'Sign up failed: ${e.message}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Google Sign-In method
  Future<void> _handlegoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VoiceSignatureScreen()),
        );
      }
    } catch (error) {
      print('Google Sign-In failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: $error')),
        );
      }    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF6F66A8),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Enter your details below & free sign up',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.0,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Your Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorText: _emailError,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Create Password',
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
                            errorText: _passwordError,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            errorText: _confirmPasswordError,
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _isCheckboxChecked,
                              onChanged: (value) {
                                setState(() {
                                  _isCheckboxChecked = value!;
                                });
                                _validateForm();
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'By creating an account you agree to our terms & conditions.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isFormValid
                                ? _createAccount // Calls Firebase sign-up method
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isFormValid ? Color(0xFF6F66A8) : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
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
                                'Or Sign Up with',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap:
                                  _handlegoogleSignIn, // Google Sign-In method
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                backgroundImage:
                                    AssetImage('assets/google.png'),
                              ),
                            ),
                            const SizedBox(
                                width: 20), // Space between Google and Facebook
                            GestureDetector(
                              onTap: () {
                                // Add Facebook Sign-in logic here
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
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: 'Log in',
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

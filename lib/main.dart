import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thackur/screens/home_screen.dart';
import 'package:thackur/screens/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Guard against 'duplicate-app' error on hot restart:
  // Firebase persists in the native layer but main() re-runs on hot restart.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Razorpay Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD6CFE1)),
      ),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return const HomeScreen();
          } else {
            return const LoginPage();
          }
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SignInScreen(),
//     );
//   }
// }

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});

//   @override
//   _SignInScreenState createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   String? userEmail;

//   Future<void> signInWithGoogle() async {
//     final GoogleSignIn googleSignIn = GoogleSignIn();
//     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//     if (googleUser == null) {
//       return; // User canceled the sign-in
//     }

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//     final AuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     await FirebaseAuth.instance.signInWithCredential(credential);

//     setState(() {
//       userEmail = googleUser.email;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Login successful")),
//     );
//   }

//   Future<void> signOut() async {
//     await GoogleSignIn().signOut();
//     await FirebaseAuth.instance.signOut();
//     setState(() {
//       userEmail = null;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Logged out successfully")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Google Sign-In")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             userEmail == null
//                 ? ElevatedButton(
//               onPressed: signInWithGoogle,
//               child: Text("Login with Google"),
//             )
//                 : Column(
//               children: [
//                 Text("Logged in as: $userEmail"),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: signOut,
//                   child: Text("Logout"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

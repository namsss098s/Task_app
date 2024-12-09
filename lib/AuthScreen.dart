import 'package:final_exam/ContractScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'SignUpScreen.dart';

class Authscreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<Authscreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Sign-In method
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the login
        return null;
      }

      // 2. Get Google authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Get Google credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 5. Check if user exists in the database
        final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
        final userSnapshot = await userRef.get();

        if (!userSnapshot.exists) {
          // 6. If user does not exist, create a new user in the database
          await userRef.set({
            'email': user.email,
            'name': user.displayName,
            'provider': 'Google',
            'profilePicture': user.photoURL,
          });
        }
      }
      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }


  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Login method
  Future<void> _login() async {
    try {
      if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in both fields')),
        );
        return;
      }

      // Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in the database
        final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
        final userSnapshot = await userRef.get();

        if (!userSnapshot.exists) {
          // If user does not exist, create a new user in the database
          await userRef.set({
            'email': user.email,
            'provider': 'Email/Password',
          });
        }

        // Navigate to ContractScreen on successful login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ContractScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Log in to Task & Habit Manager'),
        backgroundColor: Colors.purpleAccent[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back! Sign in using your Gmail account or your account to continue using our service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Social Media Login Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () async {
                    final user = await signInWithGoogle();
                    if (user != null) {
                      print('Successfully signed in with account: ${user.displayName}');
                    }
                  },
                  child: Text('Sign in with Google!', style: TextStyle(color: Colors.red[300])),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Center(child: Text('-------------OR------------')),

            const SizedBox(height: 20),
            // Email and Password Text Fields
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.pinkAccent[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text('Login', style: TextStyle(color: Colors.cyan[700])),
            ),

            const SizedBox(height: 20),

            // Footer Text (for sign-up redirection)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

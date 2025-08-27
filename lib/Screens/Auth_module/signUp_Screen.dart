import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/Screens/home_screen/home_screen.dart';
import 'package:flutter_application_1/screens/auth_module/signIn_Screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUpWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'createdAt': Timestamp.now(),
            });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Signup failed')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // handle errors how you prefer (logging, rethrow, etc.)
      rethrow;
    }
  }

  // optional: sign out from both Firebase and Google
  Future<void> signOutGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
              color: Colors.grey[800],
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Full Name
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter name'
                            : null,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 15),

                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            (value != null && value.contains('@'))
                            ? null
                            : 'Enter valid email',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 15),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            (value != null && value.length >= 6)
                            ? null
                            : 'Password must be at least 6 characters',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 15),

                      // Confirm Password
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) => value == passwordController.text
                            ? null
                            : 'Passwords do not match',
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 25),

                      // Sign Up Button
                      GestureDetector(
                        onTap: _isLoading ? null : _signUpWithEmail,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 30.0,
                                  )
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                      const Divider(color: Colors.amber),
                      const SizedBox(height: 15),

                      // Google Sign Up Button
                      GestureDetector(
                        onTap: _isLoading ? null : _signInWithGoogle,
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.amber),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/google.png", height: 24),
                              const SizedBox(width: 10),
                              const Text(
                                "Sign up with Google",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Already have account? Sign In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SigninScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

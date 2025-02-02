import 'package:flutter/material.dart';
import 'package:fix_my_city/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset link has been sent to $email'),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LogIn()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF009944),
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Column(children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Enter the email associated with your account and we'll send an email with code to reset your password",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Color(0xFF838383),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF838383),
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  String email = emailController.text.trim();
                  sendPasswordResetEmail(email);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009944),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 131, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
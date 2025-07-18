import 'package:fix_my_city/screens/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:fix_my_city/widgets/worker_bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerLogIn extends StatefulWidget {
  const WorkerLogIn({super.key});

  @override
  State<WorkerLogIn> createState() => _LogInState();
}

class _LogInState extends State<WorkerLogIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  Future<bool> doesUserExist(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('workers')
        .where('email', isEqualTo: email.toLowerCase())
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> logIn() async {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => emailError = 'Email is required');
    }

    if (password.isEmpty) {
      setState(() => passwordError = 'Password is required');
    }

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
      setState(() => emailError = 'Invalid email format');
      return;
    }

    bool userExists = await doesUserExist(email);
    if (!userExists) {
      setState(() {
        emailError = 'No account found for this email.';
      });
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      final snapshot = await FirebaseFirestore.instance
          .collection('workers')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final workerId = doc['workerId'];
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerBottomNavBar(workerId: workerId),
            ),
          );
        }
      } else {
        // just in case
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Worker data not found.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-credential') {
          passwordError = 'Incorrect Password';
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Authentication failed'),
              backgroundColor: Colors.red.shade400,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
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
          'Worker Log In',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
            child: Column(
              children: [
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
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF838383),
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: emailError == null
                          ? Colors.grey
                          : Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: emailError == null
                          ? Colors.blue
                          : Colors.red),
                    ),
                    errorText: emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF838383),
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: passwordError == null
                          ? Colors.grey
                          : Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: emailError == null
                          ? Colors.blue
                          : Colors.red),
                    ),
                    errorText: passwordError,
                  ),
                ),
                const SizedBox(height: 2),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotPassword()));
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF838383),
                        fontSize: 14,
                      ),
                    ),
                  )
                ]),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: logIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009944),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 137.5, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 16,
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
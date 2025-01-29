import 'package:flutter/material.dart';
import 'package:fix_my_city/screens/reset_password.dart';
import 'dart:async';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  int secondsRemaining = 120;
  late Timer timer;
  bool isResendVisible = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      {
        if (secondsRemaining > 0) {
          setState(() {
            secondsRemaining--;
          });
        } else {
          setState(() {
            isResendVisible = true;
            timer.cancel();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    otpController.dispose();
    super.dispose();
  }

  String getFormattedTime() {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF009944),
        title: const Text(
          'Verify OTP',
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
                  "Enter your OTP which has been sent to your email and completely verify your account",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Color(0xFF838383),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                keyboardType: TextInputType.number,
                controller: otpController,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveColor: Colors.grey,
                  activeColor: const Color(0xFF009944),
                  selectedColor: const Color(0xFF009944),
                ),
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),
              isResendVisible
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          secondsRemaining = 120;
                          isResendVisible = false;
                          startTimer();
                        });
                      },
                      child: const Text(
                        'Resend',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    )
                  : Text(
                      'Resend in ${getFormattedTime()}',
                      style: const TextStyle(
                          color: Color(0xFF838383), fontSize: 16),
                    ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ResetPassword()));
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

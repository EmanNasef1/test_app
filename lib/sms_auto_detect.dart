import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class SMSAutoDetect extends StatefulWidget {
  const SMSAutoDetect({super.key});

  @override
  State<SMSAutoDetect> createState() => _SMSAutoDetectState();
}

class _SMSAutoDetectState extends State<SMSAutoDetect> {
  final TextEditingController _otpController = TextEditingController();
  final String simulatedOTP = "123456";

  @override
  void initState() {
    super.initState();
    // _simulateSmsMessage();
  }

  void _simulateSmsMessage() async {
    await Future.delayed(const Duration(seconds: 2));
    _otpController.text = simulatedOTP;
  }

  void _verifyOTP(String otp) {
    if (otp == simulatedOTP) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Verified Successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter the OTP sent to your phone'),
            const SizedBox(height: 16),
            PinFieldAutoFill(
              controller: _otpController,
              codeLength: 6,
              onCodeChanged: (code) {
                if (code != null && code.length == 6) {
                  _verifyOTP(code);
                }
              },
              decoration: UnderlineDecoration(
                colorBuilder: const FixedColorBuilder(Colors.black),
                textStyle: const TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _simulateSmsMessage();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP Resent! Check your SMS.')),
                );
              },
              child: const Text('send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;

  void _sendResetEmail() async {
    setState(() {
      _errorMessage = null;
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Email can't be empty.";
      });
      return;
    }

    // Call resetPassword function from the provider
    final error = await Provider.of<UserProvider>(context, listen: false).resetPassword(email);

    if (error == null) {
      // Success: Show notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to $email.'),
          backgroundColor: Colors.green,
        ),
      );
      // Return to the login page
      if (mounted) Navigator.pop(context);
    } else {
      // Failure: Display error
      setState(() {
        _errorMessage = error;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter you email to receive a password reset link.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
              ),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _sendResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Send Reset Password Link', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
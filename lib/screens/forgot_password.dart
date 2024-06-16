import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool showText = false;
  String email = '';

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      email = _emailController.text;

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
        if (mounted) {
          showSnackBar('Password reset email sent', context);
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) showSnackBar(e.message ?? 'An error occurred', context);
      } finally {
        setState(() {
          _isLoading = false;
          showText = true;
        });
      }
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
      backgroundColor: lightGreen,
      appBar: AppBar(
        // backgroundColor: tealColor,
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      child: const Text('Reset Password'),
                    ),
              const SizedBox(height: 16.0),
              showText
                  ? Text(
                      'Reset your password using the link in the email sent to $email.\nThen log in again using your new password.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    )
                  : const Text(''),
            ],
          ),
        ),
      ),
    );
  }
}

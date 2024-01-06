import 'package:customer_app/pages/login_page.dart';
import 'package:customer_app/resources/auth_methods.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:customer_app/widgets/text_field_input.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void signUp() async {
    setState(() {
      _isLoading = true;
    });
    String name = _nameController.text;

    String res = await AuthMethods().signUpUser(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (res != "success" && context.mounted) {
      showSnackBar(res, context);
    } else if (context.mounted) {
      showSnackBar('Welcome $name!', context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: tealColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 64,
                ),
                const Image(
                  image: AssetImage('assets/8.png'),
                  height: 128,
                  width: 128,
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFieldInput(
                  icon: const Icon(
                    Icons.person,
                    color: Colors.black54,
                  ),
                  textEditingController: _nameController,
                  hintText: 'Enter your name',
                  textInputType: TextInputType.text,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextFieldInput(
                  icon: const Icon(
                    Icons.email_rounded,
                    color: Colors.black54,
                  ),
                  textEditingController: _emailController,
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextFieldInput(
                  icon: const Icon(
                    Icons.phone,
                    color: Colors.black54,
                  ),
                  textEditingController: _phoneController,
                  hintText: 'Enter your phone number',
                  textInputType: TextInputType.number,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextFieldInput(
                  icon: const Icon(
                    Icons.password_rounded,
                    color: Colors.black54,
                  ),
                  textEditingController: _passwordController,
                  hintText: 'Create a password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                const SizedBox(
                  height: 32,
                ),
                InkWell(
                  onTap: signUp,
                  child: Container(
                    width: 150,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      color: Colors.tealAccent,
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign up',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 70,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: const Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: GestureDetector(
                        onTap: navigateToLogin,
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.tealAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

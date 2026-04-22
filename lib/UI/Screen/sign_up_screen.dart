import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "🎓 Academix",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 30),

                  Text(
                    "Create Account",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),

                  SizedBox(height: 25),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter email";
                      }

                      if (!EmailValidator.validate(value)) {
                        return "Enter a valid email";
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter password";
                      } else if (value.length < 6) {
                        return "Enter at least 6 character";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirm",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onTapSignUpButton,
                      child: Text("Sign Up"),
                    ),
                  ),

                  SizedBox(height: 15),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Have an account? ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _onTapSignInButton,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapSignInButton() {
    Navigator.pushNamed(context, '/sign-in');
  }

  Future<void> _onTapSignUpButton() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      trueScaffoldMessage(context, 'Account created successfully🎉 || Sign In');

      _clearController();

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pushNamed(context, "/sign-in");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'email-already-in-use') {
        falseScaffoldMessage(context, 'This email is already registered');
      } else if (e.code == 'invalid-email') {
        falseScaffoldMessage(context, 'Invalid email address');
      } else if (e.code == 'weak-password') {
        falseScaffoldMessage(context, 'Password is too weak');
      } else {
        falseScaffoldMessage(context, 'Something went wrong');
      }
    }
  }

  void _clearController() {
    _emailController.clear();
    _passwordController.clear();
    _confirmController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}

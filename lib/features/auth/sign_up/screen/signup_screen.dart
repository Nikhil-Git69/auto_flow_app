import 'package:auto_flow/features/auth/login/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {


  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              Center(child: Image.asset('assets/logo/auto_flow_logo_xl.png')),

              const SizedBox(height: 20),

              Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CustTextfield(
                      controller: nameController,
                      labelText: "Full Name",
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 16),

                    CustTextfield(
                      controller: emailController,
                      labelText: "E-mail",
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 16),

                    CustTextfield(
                      controller: passwordController,
                      labelText: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 16),

                    CustTextfield(
                      controller: confirmController,
                      labelText: "Confirm Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 24),

                    CustomButton(
                      text: "SIGN UP",
                      onPressed: () {
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  GestureDetector(
                    onTap: () {
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())); // go back to login
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

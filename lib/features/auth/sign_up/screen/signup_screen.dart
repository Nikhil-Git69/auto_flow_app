import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/core/helper/form_validation.dart';
import 'package:auto_flow/features/auth/login/screen/login_screen.dart';
import 'package:auto_flow/features/auth/sign_up/screen/verify_email_screen.dart';
import 'package:auto_flow/features/auth/sign_up/service/signup_service.dart';
import 'package:auto_flow/features/navbar/screen/navbar_screen.dart';
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

  // Default values as they are not in UI
  final String collegeName = "Default College";
  final String role = "student";

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  Future<void> handleSignup() async {
    setState(() => isLoading = true);

    final response = await SignupService.signup(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      collegeName: collegeName,
      role: role,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (response['success'] == true) {
      // New flow: backend requires email verification
      if (response['requiresVerification'] == true) {
        final verifyEmail =
            response['email'] as String? ?? emailController.text.trim();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailScreen(
              email: verifyEmail,
              onVerified: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => NavBarScreen()),
                (_) => false,
              ),
            ),
          ),
        );
        return;
      }

      // Legacy: token returned directly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account Created Successfully"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavBarScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Signup Failed"),
          content: Text(response['message'] ?? "Unknown error"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Okay"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppPaddings.all16,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Image.asset('assets/logo/fullscale.png', height: 100),
                ),
                const SizedBox(height: 20),
                Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: AppPaddings.all16,
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
                          validator: FormValidators.validateName,
                        ),
                        const SizedBox(height: 16),
                        CustTextfield(
                          controller: emailController,
                          labelText: "E-mail",
                          icon: Icons.email_outlined,
                          validator: FormValidators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        CustTextfield(
                          controller: passwordController,
                          labelText: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: FormValidators.validatePassword,
                        ),
                        const SizedBox(height: 16),
                        CustTextfield(
                          controller: confirmController,
                          labelText: "Confirm Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) =>
                              FormValidators.validateConfirmPassword(
                                value,
                                confirmController.text,
                              ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: isLoading ? "Signing up..." : "Signup",
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    handleSignup();
                                  }
                                },
                        ),
                      ],
                    ),
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
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
      ),
    );
  }
}

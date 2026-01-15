import 'package:auto_flow/features/auth/sign_up/screen/signup_screen.dart';
import 'package:auto_flow/features/student_portal/navbar/screen/navbar_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              const SizedBox(height: 50),

              Text(
                "Sign In",
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
                      color: colorScheme.primary.withValues( alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CustTextfield(
                      controller: emailController,
                      labelText: "E-mail",
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 16),

                    /// Password Field
                    CustTextfield(
                      controller: passwordController,
                      labelText: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: colorScheme.primary,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                        ),
                        Text(
                          "Remember me",
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    CustomButton(
                      text: "LOG IN",
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NavBarScreen()));
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
                    "Don't have an account? ",
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  GestureDetector(
                    onTap: ()
                    {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                    },
                    child: Text(
                      "Create",
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

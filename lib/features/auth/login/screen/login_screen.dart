import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/features/auth/forgot_password/screen/verify_email_screen.dart';
import 'package:auto_flow/features/auth/sign_up/screen/signup_screen.dart';
import 'package:auto_flow/features/navbar/screen/navbar_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';
import 'package:auto_flow/features/auth/login/service/login_service.dart';
import 'package:auto_flow/features/auth/sign_up/screen/signup_otp_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Email and password are required");
      return;
    }

    setState(() => _isLoading = true);

    final response = await LoginService.login(
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response["success"] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavBarScreen()),
      );
      return;
    }

    if (response["unverified"] == true || response["code"] == 422) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SignupOtpScreen(
            signupMail: email,
            redoOtp: true,
          ),
        ),
      );
      return;
    }

    _showSnack(response["message"] ?? "Login failed");
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

                SizedBox(height: 60),


                Center(child: Image.asset('assets/logo/fullscale.png', height: 120,)),

                SizedBox(height: 25),

                Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 50),

                Container(
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
                            onPressed: ()
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
                            },
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      CustomButton(
                        text: _isLoading ? "Logging in..." : "Log in",
                        onPressed: _isLoading ? null : _handleLogin,
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
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()),
                        );
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
      ),
    );
  }
}

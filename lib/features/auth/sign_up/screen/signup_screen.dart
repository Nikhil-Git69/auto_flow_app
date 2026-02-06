import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/core/helper/form_validation.dart';
import 'package:auto_flow/features/auth/login/screen/login_screen.dart';
import 'package:auto_flow/features/auth/sign_up/screen/signup_otp_screen.dart';
import 'package:auto_flow/features/auth/sign_up/service/signup_service.dart';
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
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  Future<void> handleSignup() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await SignupService.signup(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if(!mounted) return;

      if (response.success) {
        setState(() {
          isLoading = false;
        });
        final email = response.data?.email ?? emailController.text.trim();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignupOtpScreen(signupMail: email, redoOtp: false),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });

        showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
          title: Center(child: Text("Signup Failed")),
          content: Text(response.message),
          actions: [
            TextButton(onPressed: () {Navigator.pop(context);}, child: Text("Okay")),
          ],
        ));


      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
        title: Center(child: Text("Error")),
        content: Text(e.toString()),
        actions: [
          TextButton(onPressed: () {Navigator.pop(context);}, child: Text("Okay")),
        ],
      ));

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

                SizedBox(height: 60),

                Center(
                    child: Image.asset('assets/logo/fullscale.png', height: 120,),
                ),

                 SizedBox(height: 25),

                Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 50),

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
                          validator: (value) => FormValidators.validateConfirmPassword(
                            value,
                            confirmController.text,
                          ),
                        ),

                        const SizedBox(height: 24),

                        CustomButton(
                          text: isLoading ? "Signing up..." :"Signup",
                          onPressed: () {
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
      ),
    );
  }
}

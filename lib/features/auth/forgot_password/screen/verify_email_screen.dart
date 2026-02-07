import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';
import 'package:auto_flow/core/helper/form_validation.dart';
import 'package:auto_flow/features/auth/forgot_password/service/verify_email_services.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/features/auth/forgot_password/screen/verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void showSnackMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerifyEmail() async {
    final email = emailController.text.trim();

    final error = FormValidators.validateEmail(email);
    if (error != null) {
      _showErrorDialog(error);
      return;
    }

    setState(() => isLoading = true);

    final response =
    await VerifyForgetPasswordEmailService.verifyEmail(email);

    if (!mounted) return;
    setState(() => isLoading = false);

    final bool success = response["success"] == true;
    final int code = response["code"] ?? 500;
    final String message =
        response["message"] ?? "Something went wrong";

    if (success && code == 200) {
      showSnackMessage(context, message);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyForgotPasswordOtpScreen(
            email: email,
          ),
        ),
      );
    } else {
      _showErrorDialog(message);
    }
  }


  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        centerTitle: true,
        title: Text(
          "Forgot Password",
          style: AppTextStyles.midHeader(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                "Verify your email",
                style: AppTextStyles.largeHeader(context),
              ),
              const SizedBox(height: 8),

              Text(
                "Enter your registered email to receive a verification code.",
                style: AppTextStyles.subMidHeader(context)
                    .copyWith(color: cs.onSurfaceVariant),
              ),

              const SizedBox(height: 18),

              Form(
               key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: CustTextfield(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: FormValidators.validateEmail,
                        labelText: "Email Address",
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomButton(
                  onPressed: ()
                  {
                    if (_formKey.currentState!.validate()) {
                         _handleVerifyEmail();
                    }
                  },
                  text: isLoading ? "Verifying Email..." : "Verify Email",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:auto_flow/core/custom_widgets/custom_dialog.dart';
import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';
import 'package:auto_flow/core/helper/form_validation.dart';
import 'package:auto_flow/features/auth/login/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/features/auth/forgot_password/service/reset_password_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: const Text("Reset Failed"),
        content: Text(message),
        primaryButtonText: "Okay",
        onPrimaryPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }


  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomDialog(
        title: const Text("Success"),
        content: Text(message),
        primaryButtonText: "Go to Login",
        onPrimaryPressed: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        },
      ),
    );
  }


  Future<void> _handleResetPassword() async {
    final newPass = newPassController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showErrorDialog("Please fill in both password fields.");
      return;
    }

    if (newPass.length < 6) {
      _showErrorDialog("Password must be at least 6 characters.");
      return;
    }

    if (newPass != confirmPass) {
      _showErrorDialog("Passwords do not match.");
      return;
    }

    setState(() => isLoading = true);

    final response = await ResetPasswordService.resetPassword(
      email: widget.email,
      newPassword: newPass,
      otp: widget.otp,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    final bool success = response["success"] == true;
    final int code = response["code"] ?? 500;
    final String message = response["message"] ?? "Something went wrong";

    if (success && code == 200) {
      _showSuccessDialog(message);
    } else {
      _showErrorDialog(message);
    }
  }



  @override
  void dispose() {
    newPassController.dispose();
    confirmPassController.dispose();
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
        title: Text("Set New Password", style: AppTextStyles.midHeader(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text("Create a new password",
                    style: AppTextStyles.largeHeader(context)),
                const SizedBox(height: 8),

                Text(
                  "Your new password must be different from previously used passwords.",
                  style: AppTextStyles.subMidHeader(context)
                      .copyWith(color: cs.onSurfaceVariant),
                ),

                const SizedBox(height: 18),

                CustTextfield(
                  controller: newPassController,
                  labelText: "New Password",
                  isPassword: true,
                  validator: FormValidators.validatePassword,
                ),

                const SizedBox(height: 14),

                CustTextfield(
                  controller: confirmPassController,
                  labelText: "Confirm New Password",
                  isPassword: true,
                  validator:  (value) => FormValidators.validateConfirmPassword(
                    value,
                    confirmPassController.text,
                  ),
                ),


                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    onPressed: ()
                    {
                      if(_formKey.currentState!.validate())
                        {
                            _handleResetPassword();
                        }
                    },
                    text: isLoading ? "Updating..." : "Update Password",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';
import 'package:auto_flow/features/auth/forgot_password/service/verify_email_services.dart';
import 'package:auto_flow/features/auth/forgot_password/service/verify_forgotpassword_otp_service.dart';
import 'package:auto_flow/features/auth/forgot_password/service/reset_password_service.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  int _step = 1; // 1: Email, 2: OTP, 3: New Password
  bool _isLoading = false;
  String _errorMsg = "";
  String _successMsg = "";

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  Future<void> _handleEmailSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMsg = "Please enter your email");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = "";
      _successMsg = "";
    });

    final response = await VerifyForgetPasswordEmailService.verifyEmail(email);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response["success"] == true) {
        _step = 2;
        _successMsg = "OTP sent to your email";
      } else {
        _errorMsg = response["message"] ?? "Failed to send reset email";
      }
    });
  }

  Future<void> _handleOtpSubmit() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      setState(() => _errorMsg = "Please enter a valid 6-digit OTP");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = "";
      _successMsg = "";
    });

    final response = await VerifyForgotPasswordOtpService.verifyOtp(
      email: email,
      otp: otp,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response["success"] == true) {
        _step = 3;
        _successMsg = "OTP verified successfully";
      } else {
        _errorMsg = response["message"] ?? "Invalid or expired OTP";
      }
    });
  }

  Future<void> _handleResetSubmit() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPass = _newPassController.text;
    final confirmPass = _confirmPassController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _errorMsg = "Please fill in all fields");
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMsg = "Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = "";
      _successMsg = "";
    });

    final response = await ResetPasswordService.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPass,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response["success"] == true) {
      setState(() {
        _successMsg = "Password reset completely!";
        _errorMsg = "";
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      setState(() {
        _errorMsg = response["message"] ?? "Failed to reset password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String title = "Reset Password";
    if (_step == 2) title = "Verify OTP";
    if (_step == 3) title = "New Password";

    String subtitle = "Enter your email address to receive an OTP.";
    if (_step == 2) {
      subtitle = "We've sent a 6-digit code to ${_emailController.text}";
    }
    if (_step == 3) {
      subtitle = "Enter your new password.";
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: AppPaddings.all24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            if (_errorMsg.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: AppPaddings.all12,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_successMsg.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: AppPaddings.all12,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMsg,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_step == 1)
              CustTextfield(
                controller: _emailController,
                labelText: "Email address",
                icon: Icons.email_outlined,
              ),
            if (_step == 2)
              CustTextfield(
                controller: _otpController,
                labelText: "Enter 6-digit OTP",
                icon: Icons.lock_clock_outlined,
                keyboardType: TextInputType.number,
              ),
            if (_step == 3) ...[
              CustTextfield(
                controller: _newPassController,
                labelText: "New Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustTextfield(
                controller: _confirmPassController,
                labelText: "Confirm Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: _isLoading
                  ? "Processing..."
                  : (_step == 1
                        ? "Send OTP"
                        : _step == 2
                        ? "Verify"
                        : "Save Password"),
              onPressed: _isLoading
                  ? null
                  : (_step == 1
                        ? _handleEmailSubmit
                        : _step == 2
                        ? _handleOtpSubmit
                        : _handleResetSubmit),
            ),
            if (_step == 1) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Remembered it? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

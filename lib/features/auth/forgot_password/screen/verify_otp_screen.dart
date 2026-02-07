import 'dart:async';

import 'package:auto_flow/features/auth/forgot_password/service/verify_forgotpassword_otp_service.dart';
import 'package:auto_flow/service/otp/resend_otp_service.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/features/auth/forgot_password/screen/reset_password_screen.dart';


// import 'package:auto_flow/service/forgot_password/verify_forgot_password_otp_service.dart';
// import 'package:auto_flow/service/otp/resend_otp_service.dart';

class VerifyForgotPasswordOtpScreen extends StatefulWidget {
  final String email;

  const VerifyForgotPasswordOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyForgotPasswordOtpScreen> createState() =>
      _VerifyForgotPasswordOtpScreenState();
}

class _VerifyForgotPasswordOtpScreenState
    extends State<VerifyForgotPasswordOtpScreen> {
  final TextEditingController pinController = TextEditingController();

  bool isLoading = false;
  bool isOtpInvalid = false;
  bool canResend = false;

  Timer? _timer;
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier(30);

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

  void _startTimer() {
    _timer?.cancel();
    setState(() => canResend = false);
    _remainingSecondsNotifier.value = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSecondsNotifier.value > 1) {
        _remainingSecondsNotifier.value--;
      } else {
        _remainingSecondsNotifier.value = 0;
        timer.cancel();
        if (!mounted) return;
        setState(() => canResend = true);
      }
    });
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Verification Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerifyOtp() async {
    final otp = pinController.text.trim();

    if (otp.length != 6) {
      _showErrorDialog("Please enter a valid 6-digit OTP");
      return;
    }

    setState(() {
      isLoading = true;
      isOtpInvalid = false;
    });

    final response = await VerifyForgotPasswordOtpService.verifyOtp(
      email: widget.email,
      otp: otp,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    final bool success = response["success"] == true;
    final int code = response["code"] ?? 500;
    final String message = response["message"] ?? "Something went wrong";

    if (success && code == 200) {
      showSnackMessage(context, message);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email,otp: otp ),
        ),
      );
    } else {
      setState(() => isOtpInvalid = true);
      _showErrorDialog(message);
    }
  }

  Future<void> _handleResendOtp() async {
    if (!canResend) return;

    final response = await ResendOtpService.resendOtp(
      email: widget.email,
      type: "forgot",
    );

    if (!mounted) return;

    if (response["code"] == 200) {
      showSnackMessage(context, response["message"]);
      pinController.clear();
      setState(() => isOtpInvalid = false);
      _startTimer();
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Resend Failed"),
          content: Text(response["message"] ?? "Something went wrong."),
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
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remainingSecondsNotifier.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        centerTitle: true,
        title: Text("Verify OTP", style: AppTextStyles.midHeader(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text("Enter the 6-digit code",
                  style: AppTextStyles.largeHeader(context)),
              const SizedBox(height: 8),

              Text(
                "We sent a verification code to:",
                style: AppTextStyles.subMidHeader(context)
                    .copyWith(color: cs.onSurfaceVariant),
              ),

              const SizedBox(height: 8),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, size: 18, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.email,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.midHeader(context)
                            .copyWith(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              PinCodeTextField(
                appContext: context,
                controller: pinController,
                length: 6,
                keyboardType: TextInputType.number,
                autoDisposeControllers: false,
                animationType: AnimationType.fade,
                enableActiveFill: true,
                cursorColor: cs.primary,
                textStyle: AppTextStyles.midHeader(context),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 52,
                  fieldWidth: 48,
                  activeFillColor: cs.surface,
                  selectedFillColor: cs.surface,
                  inactiveFillColor: cs.surface,
                  activeColor: isOtpInvalid ? cs.error : cs.primary,
                  selectedColor: isOtpInvalid ? cs.error : cs.primary,
                  inactiveColor: isOtpInvalid ? cs.error : cs.outlineVariant,
                ),
                onChanged: (_) {},
              ),

              if (isOtpInvalid) ...[
                const SizedBox(height: 10),
                Text(
                  "Invalid OTP. Please try again.",
                  style: AppTextStyles.smallHeader(context)
                      .copyWith(color: cs.error),
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomButton(
                  onPressed: isLoading ? null : _handleVerifyOtp,
                  text: isLoading ? "Verifying Code..." : "Verify Code",
                  backgroundColor: isLoading ?cs.onSurfaceVariant  : cs.primary ,
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _remainingSecondsNotifier,
                  builder: (_, seconds, __) {
                    return TextButton(
                      onPressed: canResend ? ()
                      {
                        _handleResendOtp();
                      } : null,
                      child: Text(
                        canResend
                            ? "Resend OTP"
                            : "Resend in ${seconds}s",
                        style: AppTextStyles.subMidHeader(context)
                            .copyWith(
                          color: canResend
                              ? cs.primary
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

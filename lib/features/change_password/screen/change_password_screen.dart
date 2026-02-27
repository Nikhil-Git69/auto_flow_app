import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';
import 'package:auto_flow/features/profile/service/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await _storage.read(key: 'userId');
    if (userId == null) {
      _showSnack('Session expired. Please log in again.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ProfileService.changePassword(
      userId,
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnack('Password changed successfully!', Colors.green);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      _showSnack(result['message'] ?? 'Failed to change password', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: Padding(
        padding: AppPaddings.all16,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Requirements card ──────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorScheme.surface,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Padding(
                  padding: AppPaddings.all16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: AppTextStyles.midHeader(
                          context,
                        ).copyWith(color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      ...[
                        '• At least 1 uppercase letter',
                        '• At least 1 lowercase letter',
                        '• At least 1 digit',
                        '• At least 1 special character',
                        '• Length between 8–15 characters',
                      ].map(
                        (req) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            req,
                            style: AppTextStyles.smallHeader(
                              context,
                            ).copyWith(color: colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Form ───────────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Container(
                  padding: AppPaddings.all16,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      CustTextfield(
                        icon: Icons.lock_outline,
                        labelText: 'Current Password',
                        controller: _currentPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter your current password'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      CustTextfield(
                        icon: Icons.lock_reset,
                        labelText: 'New Password',
                        controller: _newPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Enter a new password';
                          if (v.length < 8 || v.length > 15) {
                            return 'Password must be 8–15 characters';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(v))
                            return 'Need at least 1 uppercase';
                          if (!RegExp(r'[a-z]').hasMatch(v))
                            return 'Need at least 1 lowercase';
                          if (!RegExp(r'[0-9]').hasMatch(v))
                            return 'Need at least 1 digit';
                          if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
                            return 'Need at least 1 special character';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustTextfield(
                        icon: Icons.lock_reset,
                        labelText: 'Confirm New Password',
                        controller: _confirmNewPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Please confirm your password';
                          if (v != _newPasswordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        onPressed: _isLoading ? null : _handleChangePassword,
                        text: _isLoading ? 'Changing Password...' : 'Confirm',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

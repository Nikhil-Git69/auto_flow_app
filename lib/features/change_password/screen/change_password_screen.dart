import 'dart:ffi';

import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _storage = FlutterSecureStorage();

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorScheme.surface,
                ),
                child: Padding(
                  padding: AppPaddings.all16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Password Requirements:",
                        style: AppTextStyles.midHeader(
                          context,
                        ).copyWith(color: colorScheme.onSurface),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "• At least 1 uppercase letter",
                        style: AppTextStyles.smallHeader(
                          context,
                        ).copyWith(color: colorScheme.onSurface),
                      ),
                      Text(
                        "• At least 1 lowercase letter",
                        style: AppTextStyles.smallHeader(
                          context,
                        ).copyWith(color: colorScheme.onSurface),
                      ),
                      Text(
                        "• At least 1 digit",
                        style: AppTextStyles.smallHeader(
                          context,
                        ).copyWith(color: colorScheme.onSurface),
                      ),
                      Text(
                        "• At least 1 special character",
                        style: AppTextStyles.smallHeader(
                          context,
                        ).copyWith(color: colorScheme.onSurface),
                      ),
                      Text(
                        "• Length between 8-15 characters",
                        style: AppTextStyles.smallHeader(
                          context,
                        ).copyWith(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
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
                        icon: Icons.lock,
                        labelText: "Old Password",
                        controller: oldPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      const SizedBox(height: 24),

                      CustTextfield(
                        icon: Icons.lock,
                        labelText: "New Password",
                        controller: newPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      const SizedBox(height: 24),

                      CustTextfield(
                        icon: Icons.lock,
                        labelText: "Confirm New Password",
                        controller: confirmNewPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      const SizedBox(height: 24),

                      CustomButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                           
                                }
                              },
                        text: _isLoading ? "Changing Password..." : "Confirm",
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

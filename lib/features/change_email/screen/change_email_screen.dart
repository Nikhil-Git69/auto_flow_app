import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/core/custom_widgets/custom_textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  TextEditingController newEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Email',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Set up new email",
              style: AppTextStyles.largeHeader(
                context,
              ).copyWith(color: colorScheme.onSurface),
            ),
            SizedBox(height: 5),

            Text(
              "Enter new email and password to change your email.",
              style: AppTextStyles.smallHeader(
                context,
              ).copyWith(color: colorScheme.onSurface),
            ),
            SizedBox(height: 20),

            Container(
              padding: AppPaddings.all16,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  width: 2,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustTextfield(
                      icon: Icons.mail,
                      labelText: "New Email",
                      keyboardType: TextInputType.emailAddress,
                      controller: newEmailController,
                    ),

                    SizedBox(height: 24),

                    CustTextfield(
                      icon: Icons.password,
                      isPassword: true,
                      labelText: "Password",
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                    ),

                    SizedBox(height: 24),

                    CustomButton(
                      onPressed: () {},
                      text: _isLoading ? "Changing Email..." : "Confirm",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    newEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

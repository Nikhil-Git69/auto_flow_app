import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/features/auth/login/screen/login_screen.dart';
import 'package:auto_flow/features/change_email/screen/change_email_screen.dart';
import 'package:auto_flow/features/change_password/screen/change_password_screen.dart';
import 'package:auto_flow/features/legalities/privacy_policy/screen/privacy_policy_screen.dart';
import 'package:auto_flow/features/legalities/terms_and_conditions/screen/terms_and_conditions_screen.dart';
import 'package:auto_flow/features/theme_setting/screen/theme_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/features/settings/widgets/settings_section_card.dart';
import 'package:auto_flow/features/settings/widgets/settings_tile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.primary),
        ),
        actions: [
          Padding(
            padding: AppPaddings.horizontal18,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    title: Center(child: Text("Logout")),
                    content: SizedBox(
                      height: 50,
                      child: Center(
                        child: Text("Are you sure you want to log out?"),
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                          ),

                          Expanded(
                            child: CustomButton(
                              onPressed: () async {
                                final storage = const FlutterSecureStorage();

                                await storage.delete(key: 'accessToken');

                                if (!context.mounted) return;

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              text: "Logout",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              child: Icon(Icons.exit_to_app),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppPaddings.all16,
        children: [
          SettingsSection(
            title: "Account & Security",
            children: [
              SettingsTile(
                icon: Icons.key,
                title: "Change Password",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.mail_lock,
                title: "Change Email",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeEmailScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          SettingsSection(
            title: "Settings",
            children: [
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: "Notification Settings",
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.dark_mode,
                title: "Theme Settings",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThemeSettingScreen(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.language_outlined,
                title: "Language",
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          SettingsSection(
            title: "Support",
            children: [
              SettingsTile(
                icon: Icons.help_outline,
                title: "Help Centre",
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.privacy_tip,
                title: "Privacy Policy",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (Context) => PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.handshake,
                title: "Terms and Conditions",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermsAndConditionsScreen(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.delete_outline,
                title: "Delete Account",
                isDestructive: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

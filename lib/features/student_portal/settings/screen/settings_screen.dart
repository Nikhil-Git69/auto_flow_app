import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_dialog.dart';
import 'package:auto_flow/features/student_portal/theme_setting/screen/theme_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/features/student_portal/settings/widgets/profile_Header.dart';
import 'package:auto_flow/features/student_portal/settings/widgets/settings_section_card.dart';
import 'package:auto_flow/features/student_portal/settings/widgets/settings_tile.dart';

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
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          Padding(
            padding: AppPaddings.horizontal18,
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.exit_to_app),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileHeader(colorScheme: colorScheme),

          const SizedBox(height: 24),

          SettingsSection(
            title: "Account & Security",
            children: [
              SettingsTile(
                icon: Icons.key,
                title: "Change Password",
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.mail_lock,
                title: "Change Email",
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.confirmation_num,
                title: "2 Factor Authentication",
                onTap: () {},
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
                icon: Icons.rule_outlined,
                title: "Community Rules",
                onTap: () {},
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: "About",
                onTap: () {},
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

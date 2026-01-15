import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_flow/core/theme/theme_notifier.dart';

class ThemeSettingScreen extends StatelessWidget {
  const ThemeSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final currentMode = themeNotifier.themeMode;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildTile({
      required IconData icon,
      required String title,
      required ThemeMode mode,
    }) {
      final isSelected = currentMode == mode;

      return ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: Text(
          title,
          style: AppTextStyles.subMidHeader(context).copyWith(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check, color: colorScheme.primary)
            : null,
        onTap: () {
          // Use context.read here to avoid unnecessary rebuilds
          final notifier = context.read<ThemeNotifier>();
          switch (mode) {
            case ThemeMode.light:
              notifier.setLightMode();
              break;
            case ThemeMode.dark:
              notifier.setDarkMode();
              break;
            case ThemeMode.system:
              notifier.setSystemMode();
              break;
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theme Setting',
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
      body: Column(
        children: [
          const SizedBox(height: 16),
          buildTile(
            icon: Icons.light_mode,
            title: "Light Mode",
            mode: ThemeMode.light,
          ),
          buildTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            mode: ThemeMode.dark,
          ),
          buildTile(
            icon: Icons.phone_android,
            title: "System Default",
            mode: ThemeMode.system,
          ),
        ],
      ),
    );
  }
}

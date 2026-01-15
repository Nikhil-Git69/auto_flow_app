import 'package:flutter/material.dart';


class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tileColor = isDestructive
        ? colorScheme.error
        : colorScheme.onSurface;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? colorScheme.error
            : colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: tileColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}

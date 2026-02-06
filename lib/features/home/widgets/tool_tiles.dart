import 'package:flutter/material.dart';
import 'package:auto_flow/constants/app_textstyles.dart';

class ToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ToolTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title, style: AppTextStyles.subMidHeader(context).copyWith(color: colorScheme.onSurface)),
      subtitle: Text(subtitle, style: AppTextStyles.smallHeader(context).copyWith(color: colorScheme.onSurface)),
      trailing: Icon(Icons.chevron_right, color: colorScheme.primary),
    );
  }
}

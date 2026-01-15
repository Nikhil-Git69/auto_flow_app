import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget title;
  final Widget content;

  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;

  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: colors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle(
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
              child: title,
            ),

            const SizedBox(height: 12),

            // 📄 Content
            DefaultTextStyle(
              style: theme.textTheme.bodyMedium!,
              child: content,
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (secondaryButtonText != null &&
                    onSecondaryPressed != null)
                  TextButton(
                    onPressed: onSecondaryPressed,
                    child: Text(secondaryButtonText!),
                  ),

                const SizedBox(width: 8),

                FilledButton(
                  onPressed: onPrimaryPressed,
                  child: Text(primaryButtonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

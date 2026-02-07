import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final double? width;
  final double? height;
  final VoidCallback? onPressed;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final Color? backgroundColor;

  const CustomButton({
    super.key,
    this.onPressed,
    this.text,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.width,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDisabled = onPressed == null;

    final Color effectiveBackgroundColor = isDisabled
        ? colorScheme.onSurface.withValues(alpha: 0.3)
        : backgroundColor ?? colorScheme.primary;

    final Color effectiveTextColor = isDisabled
        ? colorScheme.onSurface.withValues(alpha: 0.6)
        : textColor ?? colorScheme.onPrimary;

    return SizedBox(
      height: height ?? 50,
      width: width ?? MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: textColor ?? colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text ?? "",
          style: TextStyle(
            color: textColor ?? colorScheme.onPrimary,
            fontSize: fontSize,
            fontWeight: fontWeight ?? FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

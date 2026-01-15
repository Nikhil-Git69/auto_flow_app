import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle subMidHeader(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle midHeader(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle largeHeader(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle smallHeader(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }
}

import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  final String title;
  final String content;

  const PolicyPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: AppTextStyles.subMidHeader(
            context,
          ).copyWith(color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

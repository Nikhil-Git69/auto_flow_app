import 'package:flutter/material.dart';
import 'package:auto_flow/features/legalities/privacy_policy/widgets/policy_page.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _privacyPolicyText = '''
Privacy Policy

Last updated: 16 January 2026

We respect your privacy and are committed to protecting your data.

1. Data We Collect
We collect documents uploaded by users and basic app usage information necessary to provide our services.

2. Document Storage
Uploaded documents are securely stored on our servers to enable analysis, feedback, corrections, and future access.

3. Use of Data
Your data is used only to:
• Analyze and improve documents
• Provide feedback and corrected versions
• Improve app functionality and reliability

4. Data Sharing
We do not sell or rent user data. Data may be processed using trusted third-party services solely to deliver app features.

5. Data Security
We use reasonable technical and organizational measures to protect your information.

6. User Control
You may request deletion of your data by contacting support.

7. Contact
If you have questions about this policy, contact us at:
service.autoflow@gmail.com

''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const PolicyPage(
        title: 'Privacy Policy',
        content: _privacyPolicyText,
      ),
    );
  }
}

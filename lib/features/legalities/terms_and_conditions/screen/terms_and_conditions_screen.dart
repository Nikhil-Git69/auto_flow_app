import 'package:flutter/material.dart';
import 'package:auto_flow/features/legalities/privacy_policy/widgets/policy_page.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  static const String _termsText = '''
Terms & Services

Last updated: 16 January 2026

By using this application, you agree to the following terms.

1. Service Use
This app allows users to upload documents for analysis, feedback, and correction.

2. User Responsibility
You confirm that you own or have permission to upload any document you submit.

3. Stored Content
Uploaded documents may be stored and processed to provide ongoing and future services.

4. AI-Generated Feedback
Feedback and corrections are generated automatically and should be reviewed by the user before use.

5. Prohibited Use
You must not upload unlawful, harmful, or abusive content.

6. Service Changes
We may update, modify, or discontinue features at any time.

7. Limitation of Liability
We are not responsible for outcomes resulting from reliance on generated content.

8. Termination
We reserve the right to restrict access for misuse or policy violations.

9. Contact
For support or questions:
service.autoflow@gmail.com
''';

  @override
  Widget build(BuildContext context) {
    return const PolicyPage(title: 'Terms & Services', content: _termsText);
  }
}

import 'package:flutter/material.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/LegalContentScreen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalContentScreen(
      type: 'privacy_policy',
      title: 'Privacy Policy',
    );
  }
}

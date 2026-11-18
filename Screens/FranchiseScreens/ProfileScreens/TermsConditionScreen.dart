import 'package:flutter/material.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/LegalContentScreen.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalContentScreen(
      type: 'terms_and_conditions',
      title: 'Terms & Conditions',
    );
  }
}

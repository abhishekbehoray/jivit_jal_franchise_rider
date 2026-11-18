import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Screens/CommonScreens/Auth/OnboardingScreen/WelcomeScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/DeliveryAgentScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/PrivacyPolicyScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/TermsConditionScreen.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/EditProfileScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/CODScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/EarningsScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/ZoneManagementScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/BankDetailsScreen.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_event.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_state.dart';
import 'package:jivit_jal_2/data/repositories/auth_repository.dart';

class FranchiseProfileScreen extends StatefulWidget {
  const FranchiseProfileScreen({super.key});

  @override
  State<FranchiseProfileScreen> createState() => _FranchiseProfileScreenState();
}

class _FranchiseProfileScreenState extends State<FranchiseProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    context.read<FranchiseProfileBloc>().add(FranchiseProfileFetchRequested());
  }

  Future<void> _goToRoleSelect(BuildContext context) async {
    await _authRepository.clearTokens();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showLogoutDialog(BuildContext context) {
    final outerContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Transform.rotate(
                  angle: 0.5,
                  child: const Icon(Icons.arrow_circle_right_outlined, size: 40, color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Oh no! You're leaving...", textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Are you sure?', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Column(children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("No, I'm not leaving", textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToRoleSelect(outerContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Yes, Log me out', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final outerContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, size: 40, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              const Text("What? You're deleting your account", textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('All of your data will be deleted', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Column(children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("No, I'll not delete my account", textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToRoleSelect(outerContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Yes, Delete my account', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return BlocBuilder<FranchiseProfileBloc, FranchiseProfileState>(
      builder: (context, state) {
        final ownerName = state is FranchiseProfileSuccess ? state.data.ownerName : '---';
        final ownerEmail = state is FranchiseProfileSuccess ? state.data.ownerEmail : '---';
        final profilePhoto = state is FranchiseProfileSuccess ? state.data.profilePhoto : '';

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text('Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              centerTitle: true,
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<FranchiseProfileBloc>().add(FranchiseProfileFetchRequested());
                },
                color: AppColors.primaryBlue,
                child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.02),

                    // ── Profile Header ──────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: width * 0.2,
                            height: width * 0.2,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: state is FranchiseProfileLoading
                                ? const CircularProgressIndicator(strokeWidth: 2)
                                : ClipOval(
                                    child: profilePhoto.isNotEmpty
                                        ? Image.network(
                                            profilePhoto,
                                            width: width * 0.2,
                                            height: width * 0.2,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.person,
                                              size: width * 0.1,
                                              color: AppColors.primaryBlue,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: width * 0.1,
                                            color: AppColors.primaryBlue,
                                          ),
                                  ),
                          ),
                          SizedBox(height: height * 0.015),
                          Text(ownerName,
                              style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          SizedBox(height: height * 0.004),
                          Text(ownerEmail,
                              style: TextStyle(fontSize: width * 0.032, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // ── Personal Information & Settings ────────────────────
                    Text('Personal Information & Settings',
                        style: TextStyle(fontSize: width * 0.035, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    SizedBox(height: height * 0.01),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(children: [
                        _buildMenuItem(icon: Icons.person_outline, title: 'My Profile',
                            onTap: () => _navigateTo(context, const EditProfileScreen()), showDivider: true, width: width),
                        _buildMenuItem(icon: Icons.payments_outlined, title: 'COD',
                            onTap: () => _navigateTo(context, const CODScreen()), showDivider: true, width: width),
                        _buildMenuItem(icon: Icons.delivery_dining_outlined, title: 'Delivery Agent',
                            onTap: () => _navigateTo(context, const DeliveryAgentScreen()), showDivider: true, width: width),
                        _buildMenuItem(icon: Icons.attach_money_outlined, title: 'Earnings',
                            onTap: () => _navigateTo(context, const EarningsMenuScreen()), showDivider: true, width: width),
                        _buildMenuItem(icon: Icons.place_outlined, title: 'Zone Management',
                            onTap: () => _navigateTo(context, const ZoneManagementScreen()), showDivider: true, width: width),
                        _buildMenuItem(icon: Icons.account_balance_outlined, title: 'Bank Details',
                            onTap: () => _navigateTo(context, const BankDetailsScreen()), showDivider: false, width: width),
                      ]),
                    ),
                    SizedBox(height: height * 0.025),

                    // ── Legal ──────────────────────────────────────────────
                    Text('Legal',
                        style: TextStyle(fontSize: width * 0.035, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    SizedBox(height: height * 0.01),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(children: [
                        _buildMenuItem(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy',
                            onTap: () => _navigateTo(context, const PrivacyPolicyScreen()), showDivider: true, width: width),
                        _buildMenuItem(icon: Icons.description_outlined, title: 'Terms & Condition',
                            onTap: () => _navigateTo(context, const TermsConditionsScreen()), showDivider: false, width: width),
                      ]),
                    ),
                    SizedBox(height: height * 0.025),

                    // ── Account ─────────────────────────────────────────────
                    Text('Account',
                        style: TextStyle(fontSize: width * 0.035, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    SizedBox(height: height * 0.01),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(children: [
                        _buildMenuItem(icon: Icons.delete_outline, title: 'Delete Account',
                            onTap: () => _showDeleteAccountDialog(context), showDivider: true, width: width, isRed: true),
                        _buildMenuItem(icon: Icons.logout_outlined, title: 'Logout',
                            onTap: () => _showLogoutDialog(context), showDivider: false, width: width, isRed: true),
                      ]),
                    ),
                    SizedBox(height: height * 0.03),
                  ],
                ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
    required double width,
    bool isRed = false,
  }) {
    final color = isRed ? Colors.red : AppColors.textPrimary;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: width * 0.035),
            child: Row(
              children: [
                Icon(icon, size: width * 0.045, color: color),
                SizedBox(width: width * 0.03),
                Expanded(child: Text(title,
                    style: TextStyle(fontSize: width * 0.035, fontWeight: FontWeight.w500, color: color))),
                Icon(Icons.chevron_right, size: width * 0.045, color: AppColors.iconGray),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(margin: EdgeInsets.symmetric(horizontal: width * 0.04), height: 0.5, color: AppColors.borderLight),
      ],
    );
  }
}

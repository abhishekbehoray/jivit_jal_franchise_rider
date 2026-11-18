// Screens/RiderScreens/ProfileScreens/RiderProfileScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/PrivacyPolicyScreen.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/TermsConditionScreen.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/OrderScreen/EmptyBottleCollectionScreen.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/ProfileScreen/RiderMyProfileScreen.dart';
import 'package:jivit_jal_2/Screens/CommonScreens/Auth/OnboardingScreen/WelcomeScreen.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_event.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_state.dart';
import 'package:jivit_jal_2/data/models/rider_profile_model.dart';
import 'package:jivit_jal_2/data/repositories/auth_repository.dart';

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    context.read<RiderProfileBloc>().add(RiderProfileFetchRequested());
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _logout() async {
    await _authRepository.clearTokens();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    context.read<RiderProfileBloc>().add(RiderProfileDeleteRequested());
    final result = await context.read<RiderProfileBloc>().stream
        .firstWhere((s) => s is RiderProfileDeleteSuccess || s is RiderProfileDeleteFailure)
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () => RiderProfileDeleteFailure('Request timed out. Please check your connection.'),
        );
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (result is RiderProfileDeleteSuccess) {
      await _authRepository.clearTokens();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    } else if (result is RiderProfileDeleteFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
  }

  void _showLogoutDialog() {
    final outerContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                  child: const Icon(
                    Icons.arrow_circle_right_outlined,
                    size: 40,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Oh no! You're leaving...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Are you sure?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderLight),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "No, I'm not leaving",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Yes, Log me out',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final outerContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                child: const Icon(
                  Icons.delete_outline,
                  size: 40,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "What? You're deleting your account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'All of your data will be deleted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderLight),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "No, I'll not delete my account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteAccount();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Yes, Delete my account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
          title: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Header (Centered) ──────────────────────────────
              BlocBuilder<RiderProfileBloc, RiderProfileState>(
                builder: (context, state) {
                  RiderProfileModel? p;
                  if (state is RiderProfileSuccess) p = state.data;
                  if (state is RiderProfileUpdateSuccess) p = state.data;
                  if (state is RiderProfilePhotoUploadSuccess) p = state.data;

                  final name = p?.fullName ?? '';
                  final phone = p?.phoneNumber ?? '';
                  final photo = p?.profileImage;

                  return Center(
                    child: Column(
                      children: [
                        Container(
                          width: width * 0.2,
                          height: width * 0.2,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: (photo != null && photo.isNotEmpty)
                                ? Image.network(
                                    photo,
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
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: height * 0.004),
                        Text(
                          'Delivery Agent',
                          style: TextStyle(
                            fontSize: width * 0.032,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: height * 0.004),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              size: width * 0.03,
                              color: AppColors.iconGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: width * 0.03,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── Personal Information & Settings ──────────────────────────
              _buildSectionTitle('Personal Information & Settings'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'My Profile',
                      onTap: () => _navigateTo(context, const RiderMyProfileScreen()),
                      showDivider: true,
                      width: width,
                    ),
                    _buildMenuItem(
                      icon: Icons.qr_code_scanner_outlined,
                      title: 'Collect Empty Bottles',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EmptyBottleCollectionScreen()),
                        );
                      },
                      showDivider: false,
                      width: width,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Legal ─────────────────────────────────────────────────────
              _buildSectionTitle('Legal'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _navigateTo(context, const PrivacyPolicyScreen()),
                      showDivider: true,
                      width: width,
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms & Condition',
                      onTap: () => _navigateTo(context, const TermsConditionsScreen()),
                      showDivider: false,
                      width: width,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Account ───────────────────────────────────────────────────
              _buildSectionTitle('Account'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.delete_outline,
                      title: 'Delete Account',
                      onTap: _showDeleteAccountDialog,
                      showDivider: true,
                      width: width,
                      isRed: true,
                    ),
                    _buildMenuItem(
                      icon: Icons.logout_outlined,
                      title: 'Logout',
                      onTap: _showLogoutDialog,
                      showDivider: false,
                      width: width,
                      isRed: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
            ),
            if (_isDeleting)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
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
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: width * 0.035,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: width * 0.045,
                  color: color,
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: width * 0.045,
                  color: AppColors.iconGray,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.04),
            height: 0.5,
            color: AppColors.borderLight,
          ),
      ],
    );
  }
}
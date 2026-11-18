// Screens/RiderScreens/ProfileScreens/RiderMyProfileScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/RiderScreens/ProfileScreen/RiderEditProfileScreen.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_event.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_state.dart';
import 'package:jivit_jal_2/data/models/rider_profile_model.dart';

class RiderMyProfileScreen extends StatefulWidget {
  const RiderMyProfileScreen({super.key});

  @override
  State<RiderMyProfileScreen> createState() => _RiderMyProfileScreenState();
}

class _RiderMyProfileScreenState extends State<RiderMyProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RiderProfileBloc>().add(RiderProfileFetchRequested());
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RiderEditProfileScreen()),
                );
                if (!mounted) return;
                context.read<RiderProfileBloc>().add(RiderProfileFetchRequested());
              },
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<RiderProfileBloc, RiderProfileState>(
          builder: (context, state) {
            if (state is RiderProfileLoading || state is RiderProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RiderProfileFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<RiderProfileBloc>().add(RiderProfileFetchRequested()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            RiderProfileModel? p;
            if (state is RiderProfileSuccess) p = state.data;
            if (state is RiderProfileUpdateSuccess) p = state.data;
            if (state is RiderProfilePhotoUploadSuccess) p = state.data;
            if (p == null) return const SizedBox.shrink();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Photo ──────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: width * 0.25,
                          height: width * 0.25,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderLight,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: (p.profileImage != null && p.profileImage!.isNotEmpty)
                                ? Image.network(
                                    p.profileImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.person,
                                      size: width * 0.12,
                                      color: AppColors.primaryBlue,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: width * 0.12,
                                    color: AppColors.primaryBlue,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Personal Information ──────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    padding: EdgeInsets.all(width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoField('Full Name', p.fullName, width, height),
                        _buildDivider(),
                        _buildInfoField('Date Of Birth', _formatDate(p.dateOfBirth), width, height),
                        _buildDivider(),
                        _buildInfoField('Phone Number', p.phoneNumber, width, height),
                        _buildDivider(),
                        _buildInfoField('Email Address', p.emailAddress, width, height),
                        _buildDivider(),
                        _buildInfoField(
                            'Emergency Contact',
                            p.emergencyContact.isEmpty ? '—' : p.emergencyContact,
                            width,
                            height),
                        _buildDivider(),
                        _buildInfoField(
                            'Address', p.address.isEmpty ? '—' : p.address, width, height),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Work Information ──────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    padding: EdgeInsets.all(width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Work Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoField('Agent ID', p.agentId, width, height),
                        _buildDivider(),
                        _buildInfoField('Joining Date', _formatDate(p.joiningDate), width, height),
                        _buildDivider(),
                        _buildInfoField('Franchise Name', p.franchiseName, width, height),
                        _buildDivider(),
                        _buildInfoField(
                            'Zone / Area', p.zoneArea.isEmpty ? '—' : p.zoneArea.join(', '), width, height),
                        _buildDivider(),
                        _buildInfoField(
                            'Vehicle Number',
                            p.vehicleNumber.isEmpty ? '—' : p.vehicleNumber,
                            width,
                            height),
                        _buildDivider(),
                        _buildInfoField(
                            'Vehicle Type',
                            p.vehicleType.isEmpty ? '—' : _capitalize(p.vehicleType),
                            width,
                            height),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: height * 0.012,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.35,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: AppColors.borderLight,
    );
  }
}

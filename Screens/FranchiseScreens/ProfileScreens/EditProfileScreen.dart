// Screens/FranchiseScreens/ProfileScreens/EditProfileScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_event.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_state.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_event.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    context.read<FranchiseBankBloc>().add(FranchiseBankFetchRequested());
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    final ext = picked.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only JPG, JPEG, PNG and WEBP images are allowed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final file = File(picked.path);
    setState(() => _pickedImage = file);
    if (!mounted) return;
    context.read<FranchiseProfileBloc>().add(FranchiseProfilePhotoUploadRequested(file));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return BlocConsumer<FranchiseProfileBloc, FranchiseProfileState>(
      listener: (context, state) {
        if (state is FranchiseProfilePhotoUploadSuccess) {
          setState(() => _pickedImage = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully')),
          );
        } else if (state is FranchiseProfilePhotoUploadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final p = state is FranchiseProfileSuccess ? state.data
            : state is FranchiseProfilePhotoUploading ? state.data
            : state is FranchiseProfilePhotoUploadSuccess ? state.data
            : state is FranchiseProfilePhotoUploadFailure ? state.data
            : null;

        final isUploading = state is FranchiseProfilePhotoUploading;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Photo ──────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: isUploading ? null : _pickAndUpload,
                          child: Stack(
                            children: [
                              Container(
                                width: width * 0.25,
                                height: width * 0.25,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: _pickedImage != null
                                      ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                      : (p?.profilePhoto.isNotEmpty == true
                                          ? Image.network(p!.profilePhoto, fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Icon(Icons.person,
                                                  size: width * 0.12, color: AppColors.primaryBlue))
                                          : Icon(Icons.person, size: width * 0.12, color: AppColors.primaryBlue)),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: isUploading
                                      ? const SizedBox(
                                          width: 16, height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isUploading ? 'Uploading...' : 'Tap to change photo',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Franchise Information ──────────────────────────────────
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
                        const Text('Franchise Information',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        _buildInfoField('Franchise Name', p?.franchiseName ?? '', width, height),
                        _buildDivider(),
                        _buildInfoField('Owner Name', p?.ownerName ?? '', width, height),
                        _buildDivider(),
                        _buildInfoField('Phone Number', p?.ownerPhone ?? '', width, height),
                        _buildDivider(),
                        _buildInfoField('Email Address', p?.ownerEmail ?? '', width, height),
                        _buildDivider(),
                        _buildInfoField('Address', p?.address ?? '', width, height),
                        _buildDivider(),
                        _buildInfoField('City', p?.city ?? '', width, height),
                        _buildDivider(),
                        _buildInfoField('PIN Code', p?.pincode ?? '', width, height),
                        _buildDivider(),
                        _buildInfoField('State', p?.state ?? '', width, height),
                        _buildDivider(),
                        _buildInfoField('GST Number', p?.gstNumber ?? '', width, height),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Bank Details ───────────────────────────────────────────
                  BlocBuilder<FranchiseBankBloc, FranchiseBankState>(
                    builder: (context, bankState) {
                      final b = bankState is FranchiseBankLoaded ? bankState.data : null;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        padding: EdgeInsets.all(width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bank Details',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 16),
                            if (b == null)
                              const Text('No bank details added yet.',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
                            else ...[
                              _buildInfoField('Account Holder Name', b.accountHolderName, width, height),
                              _buildDivider(),
                              _buildInfoField('Bank Name', b.bankName, width, height),
                              _buildDivider(),
                              _buildInfoField('Account Number', b.accountNumber, width, height),
                              _buildDivider(),
                              _buildInfoField('IFSC Code', b.ifscCode, width, height),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoField(String label, String value, double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: height * 0.015),
      child: Row(
        children: [
          SizedBox(
            width: width * 0.35,
            child: Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(height: 0.5, color: AppColors.borderLight);
}

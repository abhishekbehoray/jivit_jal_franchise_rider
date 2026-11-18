// Screens/RiderScreens/ProfileScreens/RiderEditProfileScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_event.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_state.dart';
import 'package:jivit_jal_2/data/models/rider_profile_model.dart';

class RiderEditProfileScreen extends StatefulWidget {
  const RiderEditProfileScreen({super.key});

  @override
  State<RiderEditProfileScreen> createState() => _RiderEditProfileScreenState();
}

class _RiderEditProfileScreenState extends State<RiderEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emergencyContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  DateTime? _selectedDob;
  bool _dobError = false;
  File? _pickedImage;
  bool _initialized = false;

  RiderProfileModel? _extractData(RiderProfileState state) {
    if (state is RiderProfileSuccess) return state.data;
    if (state is RiderProfileUpdating) return state.data;
    if (state is RiderProfileUpdateSuccess) return state.data;
    if (state is RiderProfileUpdateFailure) return state.data;
    if (state is RiderProfilePhotoUploading) return state.data;
    if (state is RiderProfilePhotoUploadSuccess) return state.data;
    if (state is RiderProfilePhotoUploadFailure) return state.data;
    return null;
  }

  void _prefill(RiderProfileModel p) {
    if (_initialized) return;
    _initialized = true;
    _emergencyContactController.text = p.emergencyContact;
    _addressController.text = p.address;
    _vehicleNumberController.text = p.vehicleNumber;
    _vehicleTypeController.text = p.vehicleType;
    if (p.dateOfBirth != null && p.dateOfBirth!.isNotEmpty) {
      _selectedDob = DateTime.tryParse(p.dateOfBirth!);
    }
  }

  @override
  void dispose() {
    _emergencyContactController.dispose();
    _addressController.dispose();
    _vehicleNumberController.dispose();
    _vehicleTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
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
    context.read<RiderProfileBloc>().add(RiderProfilePhotoUploadRequested(file));
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 25),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  void _save() {
    final isFormValid = _formKey.currentState!.validate();
    setState(() => _dobError = _selectedDob == null);
    if (!isFormValid || _selectedDob == null) return;

    final dob = '${_selectedDob!.year.toString().padLeft(4, '0')}-'
        '${_selectedDob!.month.toString().padLeft(2, '0')}-'
        '${_selectedDob!.day.toString().padLeft(2, '0')}';

    context.read<RiderProfileBloc>().add(
          RiderProfileUpdateRequested(
            dateOfBirth: dob,
            emergencyContact: _emergencyContactController.text.trim(),
            address: _addressController.text.trim(),
            vehicleNumber: _vehicleNumberController.text.trim(),
            vehicleType: _vehicleTypeController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return BlocConsumer<RiderProfileBloc, RiderProfileState>(
      listener: (context, state) {
        if (state is RiderProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (state is RiderProfileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is RiderProfilePhotoUploadSuccess) {
          setState(() => _pickedImage = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully')),
          );
        } else if (state is RiderProfilePhotoUploadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final p = _extractData(state);
        if (p != null) _prefill(p);

        final isUploadingPhoto = state is RiderProfilePhotoUploading;
        final isSaving = state is RiderProfileUpdating;

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
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
            ),
            body: p == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Profile Photo ──────────────────────────────────
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: isUploadingPhoto ? null : _pickAndUpload,
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
                                            : ((p.profileImage?.isNotEmpty ?? false)
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
                                                  )),
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
                                        child: isUploadingPhoto
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Icon(Icons.camera_alt,
                                                size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isUploadingPhoto ? 'Uploading...' : 'Tap to change photo',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Read-only Info ──────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          padding: EdgeInsets.all(width * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildReadOnlyRow('Full Name', p.fullName),
                              const SizedBox(height: 10),
                              _buildReadOnlyRow('Phone Number', p.phoneNumber),
                              const SizedBox(height: 10),
                              _buildReadOnlyRow('Email Address', p.emailAddress),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Editable Fields ──────────────────────────────────
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date of Birth'),
                              GestureDetector(
                                onTap: () async {
                                  await _pickDob();
                                  if (_selectedDob != null) setState(() => _dobError = false);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _dobError ? Colors.red : AppColors.borderLight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedDob != null
                                              ? '${_selectedDob!.day.toString().padLeft(2, '0')}/'
                                                  '${_selectedDob!.month.toString().padLeft(2, '0')}/'
                                                  '${_selectedDob!.year}'
                                              : 'Select date of birth',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _selectedDob != null
                                                ? AppColors.textPrimary
                                                : AppColors.textHint,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today_outlined,
                                          size: 18, color: AppColors.iconGray),
                                    ],
                                  ),
                                ),
                              ),
                              if (_dobError)
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, left: 4),
                                  child: Text(
                                    'Please select date of birth',
                                    style: TextStyle(fontSize: 12, color: Colors.red),
                                  ),
                                ),
                              const SizedBox(height: 14),
                              _buildLabel('Emergency Contact'),
                              _buildTextField(
                                _emergencyContactController,
                                'Emergency contact number',
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Emergency contact is required';
                                  if (!RegExp(r'^[0-9]{10}$').hasMatch(v.trim())) return 'Enter a valid 10-digit phone number';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildLabel('Address'),
                              _buildTextField(
                                _addressController,
                                'Address',
                                maxLines: 3,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Address is required';
                                  if (v.trim().length < 10) return 'Enter a complete address (min 10 characters)';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Vehicle Information',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildLabel('Vehicle Number'),
                              _buildTextField(
                                _vehicleNumberController,
                                'e.g. GJ05AB1234',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Vehicle number is required';
                                  if (!RegExp(r'^[A-Za-z0-9]{4,15}$').hasMatch(v.trim())) return 'Enter a valid vehicle number (letters & digits only)';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildLabel('Vehicle Type'),
                              _buildTextField(
                                _vehicleTypeController,
                                'e.g. bike, scooter, car',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Vehicle type is required';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Save Button ──────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

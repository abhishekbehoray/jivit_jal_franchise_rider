// Screens/FranchiseScreens/ProfileScreens/BankDetailsScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/EditBankDetailsScreen.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_event.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_state.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FranchiseBankBloc>().add(FranchiseBankFetchRequested());
  }

  void _goToEdit(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditBankDetailsScreen()),
    );
    // Refresh after returning from edit
    if (mounted) {
      context.read<FranchiseBankBloc>().add(FranchiseBankFetchRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

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
            'Bank Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<FranchiseBankBloc, FranchiseBankState>(
          builder: (context, state) {
            if (state is FranchiseBankLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FranchiseBankFailure) {
              return Center(
                child: Text(state.message, style: const TextStyle(color: Colors.red)),
              );
            }

            final bank = state is FranchiseBankLoaded ? state.data : null;
            final hasBank = bank != null;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                children: [
                  if (!hasBank) ...[
                    // ── Empty State ──────────────────────────────────────
                    SizedBox(height: width * 0.1),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(width * 0.08),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_outlined,
                              size: width * 0.15, color: AppColors.primaryBlue.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          const Text(
                            'No Bank Details Added',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add your bank account details to receive payments.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    // ── Bank Details Card ────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(label: 'Account Holder Name', value: bank.accountHolderName, width: width, showDivider: true),
                          _buildDetailRow(label: 'Bank Name', value: bank.bankName, width: width, showDivider: true),
                          _buildDetailRow(label: 'Account Number', value: bank.accountNumber, width: width, showDivider: true),
                          _buildDetailRow(label: 'IFSC Code', value: bank.ifscCode, width: width, showDivider: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Add / Edit Button ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _goToEdit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(hasBank ? Icons.edit_outlined : Icons.add, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            hasBank ? 'Edit Bank Details' : 'Add Bank Details',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required double width,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: width * 0.04),
          child: Row(
            children: [
              SizedBox(
                width: width * 0.35,
                child: Text(label,
                    style: TextStyle(fontSize: width * 0.035, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
              ),
              Expanded(
                child: Text(value,
                    style: TextStyle(fontSize: width * 0.035, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(margin: EdgeInsets.symmetric(horizontal: width * 0.04), height: 0.5, color: AppColors.borderLight),
      ],
    );
  }
}

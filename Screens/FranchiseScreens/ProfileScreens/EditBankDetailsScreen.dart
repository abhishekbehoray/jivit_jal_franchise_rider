// Screens/FranchiseScreens/ProfileScreens/EditBankDetailsScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_event.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_state.dart';

class EditBankDetailsScreen extends StatefulWidget {
  const EditBankDetailsScreen({super.key});

  @override
  State<EditBankDetailsScreen> createState() => _EditBankDetailsScreenState();
}

class _EditBankDetailsScreenState extends State<EditBankDetailsScreen> {
  final _accountHolderCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _ifscCodeCtrl = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _accountHolderCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCodeCtrl.dispose();
    super.dispose();
  }

  void _prefillIfNeeded(FranchiseBankState state) {
    if (_prefilled) return;
    if (state is FranchiseBankLoaded) {
      _accountHolderCtrl.text = state.data.accountHolderName;
      _bankNameCtrl.text = state.data.bankName;
      _accountNumberCtrl.text = state.data.accountNumber;
      _ifscCodeCtrl.text = state.data.ifscCode;
      _prefilled = true;
    }
  }

  void _save() {
    final name = _accountHolderCtrl.text.trim();
    final bank = _bankNameCtrl.text.trim();
    final acc = _accountNumberCtrl.text.trim();
    final ifsc = _ifscCodeCtrl.text.trim();

    if (name.isEmpty || bank.isEmpty || acc.isEmpty || ifsc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<FranchiseBankBloc>().add(FranchiseBankSaveRequested(
      accountHolderName: name,
      accountNumber: acc,
      ifscCode: ifsc,
      bankName: bank,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return BlocConsumer<FranchiseBankBloc, FranchiseBankState>(
      listener: (context, state) {
        _prefillIfNeeded(state);
        if (state is FranchiseBankSaveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bank details saved successfully!')),
          );
          Navigator.pop(context);
        } else if (state is FranchiseBankSaveFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        _prefillIfNeeded(state);
        final isSaving = state is FranchiseBankSaving;

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
                'Edit Bank Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: isSaving ? null : _save,
                  child: const Text('Save',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('Account Holder Name', _accountHolderCtrl, 'Enter account holder name'),
                  const SizedBox(height: 16),
                  _buildField('Bank Name', _bankNameCtrl, 'Enter bank name'),
                  const SizedBox(height: 16),
                  _buildField('Account Number', _accountNumberCtrl, 'Enter account number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  const SizedBox(height: 16),
                  _buildField('IFSC Code', _ifscCodeCtrl, 'Enter IFSC code',
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      ]),
                  const SizedBox(height: 30),

                  // ── Save Button ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryBlue)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

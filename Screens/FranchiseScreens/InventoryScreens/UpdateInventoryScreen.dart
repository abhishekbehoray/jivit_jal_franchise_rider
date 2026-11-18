// Screens/FranchiseScreens/InventoryScreens/UpdateInventoryScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_event.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_state.dart';
import 'package:jivit_jal_2/data/models/inventory_model.dart';

class UpdateInventoryScreen extends StatefulWidget {
  final InventoryModel? inventory;
  const UpdateInventoryScreen({super.key, this.inventory});

  @override
  State<UpdateInventoryScreen> createState() => _UpdateInventoryScreenState();
}

class _UpdateInventoryScreenState extends State<UpdateInventoryScreen> {
  late final TextEditingController _filledJarsController;
  late final TextEditingController _emptyJarsController;
  late final TextEditingController _damagedJarsController;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filledJarsController = TextEditingController(text: '${widget.inventory?.filledJars ?? ''}');
    _emptyJarsController = TextEditingController(text: '${widget.inventory?.emptyJarsAtCustomers ?? ''}');
    _damagedJarsController = TextEditingController(text: '${widget.inventory?.damagedJars ?? ''}');
  }

  @override
  void dispose() {
    _filledJarsController.dispose();
    _emptyJarsController.dispose();
    _damagedJarsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final filled = int.tryParse(_filledJarsController.text.trim()) ?? widget.inventory?.filledJars ?? 0;
    final empty = int.tryParse(_emptyJarsController.text.trim()) ?? widget.inventory?.emptyJarsAtCustomers ?? 0;
    final damaged = int.tryParse(_damagedJarsController.text.trim()) ?? widget.inventory?.damagedJars ?? 0;

    context.read<FranchiseInventoryBloc>().add(InventoryUpdateRequested(
          filledJars: filled,
          emptyJarsAtCustomers: empty,
          returnedEmptyJars: widget.inventory?.returnedEmptyJars ?? 0,
          damagedJars: damaged,
          totalJars: widget.inventory?.totalJars ?? 0,
          lowStockThreshold: widget.inventory?.lowStockThreshold ?? 0,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return BlocListener<FranchiseInventoryBloc, FranchiseInventoryState>(
      listener: (context, state) {
        if (state is FranchiseInventorySaved) {
          Navigator.pop(context);
        } else if (state is FranchiseInventorySaveFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Update Inventory',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filled Jars ──────────────────────────────────────────────
            const Text(
              'Filled Jars',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(_filledJarsController, '150'),

            const SizedBox(height: 16),

            // ── Empty Jars ─────────────────────────────────────────────────
            const Text(
              'Empty Jars',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(_emptyJarsController, '120'),

            const SizedBox(height: 16),

            // ── Damaged Jars ──────────────────────────────────────────────
            const Text(
              'Damaged Jars',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(_damagedJarsController, '9'),

            const SizedBox(height: 16),

            // ── Notes ──────────────────────────────────────────────────────
            const Text(
              'Notes (optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter Notes...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ── Save Update Button ─────────────────────────────────────────
            BlocBuilder<FranchiseInventoryBloc, FranchiseInventoryState>(
              builder: (context, state) {
                final isSaving = state is FranchiseInventorySaving;
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save update',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
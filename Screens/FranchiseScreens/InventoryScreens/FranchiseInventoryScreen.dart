import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_event.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_state.dart';
import 'package:jivit_jal_2/data/models/inventory_model.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/InventoryScreens/UpdateInventoryScreen.dart';
import 'package:jivit_jal_2/Screens/CommonScreens/NotificationScreen.dart';

class FranchiseInventoryScreen extends StatefulWidget {
  const FranchiseInventoryScreen({super.key});

  @override
  State<FranchiseInventoryScreen> createState() =>
      _FranchiseInventoryScreenState();
}

class _FranchiseInventoryScreenState extends State<FranchiseInventoryScreen> {
  String _selectedTimeFilter = 'Today';

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }
  final List<String> _timeFilters = ['Today', 'This week', 'This month'];

  @override
  void initState() {
    super.initState();
    context.read<FranchiseInventoryBloc>().add(InventoryFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Inventory',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<FranchiseInventoryBloc, FranchiseInventoryState>(
        listener: (context, state) {
          if (state is FranchiseInventorySaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inventory saved successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is FranchiseInventorySaveFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FranchiseInventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FranchiseInventoryFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<FranchiseInventoryBloc>()
                        .add(InventoryFetchRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FranchiseInventoryNotFound) {
            return _buildNotFoundView(width);
          }

          final inventory = state is FranchiseInventoryLoaded
              ? state.inventory
              : (state is FranchiseInventorySaving ? state.current : null);

          if (inventory == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<FranchiseInventoryBloc>()
                  .add(InventoryFetchRequested());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.045, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStockOverview(width, inventory),
                  const SizedBox(height: 14),
                  _buildUpdateInventoryCard(context, inventory),
                  const SizedBox(height: 20),
                  const Text(
                    'Inventory List',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInventoryCard(
                    name: '20L Filled Jars',
                    description: 'Ready for delivery',
                    units: inventory.filledJars,
                    iconColor: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFFDBEAFE),
                    icon: Icons.water_drop,
                    width: width,
                  ),
                  _buildInventoryCard(
                    name: '20L Empty Jars at Customers',
                    description: 'At customer locations',
                    units: inventory.emptyJarsAtCustomers,
                    iconColor: const Color(0xFF22C55E),
                    bgColor: const Color(0xFFDCFCE7),
                    icon: Icons.water_drop_outlined,
                    width: width,
                  ),
                  _buildInventoryCard(
                    name: '20L Returned Empty Jars',
                    description: 'Ready for refilling',
                    units: inventory.returnedEmptyJars,
                    iconColor: const Color(0xFF06B6D4),
                    bgColor: const Color(0xFFCFFAFE),
                    icon: Icons.recycling,
                    width: width,
                  ),
                  _buildInventoryCard(
                    name: '20L Damaged Jars',
                    description: 'Needs replacement',
                    units: inventory.damagedJars,
                    iconColor: const Color(0xFFFF8C42),
                    bgColor: const Color(0xFFFFEDD5),
                    icon: Icons.warning_amber_rounded,
                    width: width,
                  ),
                  _buildInventoryCard(
                    name: 'Total Jars',
                    description: 'All jars (filled + empty)',
                    units: inventory.totalJars,
                    iconColor: const Color(0xFFA855F7),
                    bgColor: const Color(0xFFF3E8FF),
                    icon: Icons.inventory_2_outlined,
                    width: width,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Orange Update Inventory Card (same as home screen) ──────────────
  Widget _buildUpdateInventoryCard(BuildContext context, InventoryModel inv) {
    final thresholdCritical = inv.lowStockThreshold > 0 &&
        inv.lowStockThreshold >= inv.emptyJarsAtCustomers;
    final isLowStock = thresholdCritical ||
        (inv.lowStockThreshold > 0 && inv.filledJars <= inv.lowStockThreshold);
    final cardColor =
        thresholdCritical ? const Color(0xFFEF4444) : AppColors.primaryBlue;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filled Jars',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('${inv.filledJars}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pending Empty\nJars Return',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('${inv.emptyJarsAtCustomers}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Low Stock Alert',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          )),
                      if (isLowStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${inv.filledJars} left',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('20 Liters',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => UpdateInventoryScreen(inventory: inv)),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Update Inventory',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cardColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Not Found: show create button ────────────────────────────────────
  Widget _buildNotFoundView(double width) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 48, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Inventory Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your inventory to start tracking jars.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateInventorySheet(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Create Inventory',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Blue Stock Overview Box ───────────────────────────────────────────
  Widget _buildStockOverview(double width, InventoryModel inv) {
    // Filter label for returned jars row
    final returnedLabel = _selectedTimeFilter == 'Today'
        ? 'Today'
        : _selectedTimeFilter == 'This week'
            ? 'This Week'
            : 'This Month';

    return Container(
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stock Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                _formatDate(DateTime.now()),

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _buildStatTile('${inv.filledJars}', 'Filled Jars')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildStatTile(
                      '${inv.emptyJarsAtCustomers}', 'Empty Jars at\nCustomers')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child:
                      _buildStatTile('${inv.damagedJars}', 'Damaged Jars')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildStatTile('${inv.totalJars}', 'Total Jars')),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${inv.returnedEmptyJars}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.lightBlue[200],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Returned Empty Jars ($returnedLabel)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTodayDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.lightBlue[200],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimeFilter,
          isDense: true,
          dropdownColor: AppColors.primaryBlue,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 16),
          items: _timeFilters.map((f) {
            return DropdownMenuItem<String>(
              value: f,
              child: Text(f,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 12)),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedTimeFilter = v!),
        ),
      ),
    );
  }

  // ─── Inventory Card ────────────────────────────────────────────────────
  Widget _buildInventoryCard({
    required String name,
    required String description,
    required int units,
    required Color iconColor,
    required Color bgColor,
    required IconData icon,
    required double width,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
          EdgeInsets.symmetric(horizontal: width * 0.035, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$units',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const Text('units',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Create Inventory Bottom Sheet ────────────────────────────────────
  void _showCreateInventorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(
        value: context.read<FranchiseInventoryBloc>(),
        child: const _CreateInventorySheet(),
      ),
    );
  }
}

// ─── Create Inventory Bottom Sheet Widget ─────────────────────────────────
class _CreateInventorySheet extends StatefulWidget {
  const _CreateInventorySheet();

  @override
  State<_CreateInventorySheet> createState() => _CreateInventorySheetState();
}

class _CreateInventorySheetState extends State<_CreateInventorySheet> {
  final _filledCtrl = TextEditingController();
  final _emptyAtCustomersCtrl = TextEditingController();
  final _returnedCtrl = TextEditingController();
  final _damagedCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController();
  int _total = 0;

  @override
  void initState() {
    super.initState();
    for (final ctrl in [_filledCtrl, _emptyAtCustomersCtrl, _returnedCtrl, _damagedCtrl]) {
      ctrl.addListener(_recalculateTotal);
    }
  }

  void _recalculateTotal() {
    final filled = int.tryParse(_filledCtrl.text.trim()) ?? 0;
    final emptyAtCustomers = int.tryParse(_emptyAtCustomersCtrl.text.trim()) ?? 0;
    final returned = int.tryParse(_returnedCtrl.text.trim()) ?? 0;
    final damaged = int.tryParse(_damagedCtrl.text.trim()) ?? 0;
    setState(() {
      _total = filled + emptyAtCustomers + returned + damaged;
    });
  }

  @override
  void dispose() {
    _filledCtrl.dispose();
    _emptyAtCustomersCtrl.dispose();
    _returnedCtrl.dispose();
    _damagedCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final filled = int.tryParse(_filledCtrl.text.trim()) ?? 0;
    final emptyAtCustomers =
        int.tryParse(_emptyAtCustomersCtrl.text.trim()) ?? 0;
    final returned = int.tryParse(_returnedCtrl.text.trim()) ?? 0;
    final damaged = int.tryParse(_damagedCtrl.text.trim()) ?? 0;
    final threshold = int.tryParse(_thresholdCtrl.text.trim()) ?? 0;

    context.read<FranchiseInventoryBloc>().add(InventoryCreateRequested(
          filledJars: filled,
          emptyJarsAtCustomers: emptyAtCustomers,
          returnedEmptyJars: returned,
          damagedJars: damaged,
          totalJars: _total,
          lowStockThreshold: threshold,
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Inventory',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _field(_filledCtrl, 'Filled Jars'),
            _field(_emptyAtCustomersCtrl, 'Empty Jars at Customers'),
            _field(_returnedCtrl, 'Returned Empty Jars'),
            _field(_damagedCtrl, 'Damaged Jars'),
            _totalField(),
            _field(_thresholdCtrl, 'Low Stock Threshold'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Create',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Jars',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$_total',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: const TextStyle(
                    fontSize: 14, color: AppColors.textHint),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

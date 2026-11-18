// Screens/FranchiseScreens/ProfileScreens/EarningsDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EarningsDetailScreen extends StatefulWidget {
  const EarningsDetailScreen({super.key});

  @override
  State<EarningsDetailScreen> createState() => _EarningsDetailScreenState();
}

class _EarningsDetailScreenState extends State<EarningsDetailScreen> {
  final List<String> _months = [
    'January 2024',
    'February 2024',
    'March 2024',
    'April 2024',
    'May 2024',
    'June 2024',
    'July 2024',
    'August 2024',
    'September 2024',
    'October 2024',
    'November 2024',
    'December 2024',
  ];

  int _monthIndex = 1; // February 2024
  int _selectedDay = 17;

  String get _selectedMonth => _months[_monthIndex];

  void _previousMonth() {
    if (_monthIndex > 0) setState(() => _monthIndex--);
  }

  void _nextMonth() {
    if (_monthIndex < _months.length - 1) setState(() => _monthIndex++);
  }

  /// 0 = Monday … 6 = Sunday
  int _firstWeekdayOfMonth() {
    final date = DateTime(2024, _monthIndex + 1, 1);
    return date.weekday - 1; // weekday: 1=Mon…7=Sun → 0-based
  }

  int _daysInMonth() {
    return DateTime(2024, _monthIndex + 2, 0).day;
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Earnings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Select Date Row ──────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFFAAAAAA),
                      size: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Inline Calendar ──────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E2E2)),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    // ── Blue header: month + nav ───────────────────────
                    Container(
                      color: const Color(0xFF1A4FBE),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _previousMonth,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.chevron_left,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                          Text(
                            _selectedMonth,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: _nextMonth,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.chevron_right,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── White body: weekdays + day grid ───────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
                      child: Column(
                        children: [
                          // Weekday headers
                          Row(
                            children: const [
                              _WeekdayLabel('Mo'),
                              _WeekdayLabel('Tu'),
                              _WeekdayLabel('We'),
                              _WeekdayLabel('Th'),
                              _WeekdayLabel('Fr'),
                              _WeekdayLabel('Sa'),
                              _WeekdayLabel('Su'),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Day grid
                          _buildCalendarGrid(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Bottom Cards (2-col, inside a light bordered container) ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD0D9F5)),
                ),
                child: Row(
                  children: [
                    // Online Payments Received
                    Expanded(
                      child: _EarningsCard(
                        title: 'Online Payments\nRecieved',
                        value: 'N/A',
                      ),
                    ),
                    const SizedBox(width: 10),
                    // COD Collected
                    Expanded(
                      child: _EarningsCard(
                        title: 'COD\nCollected',
                        value: 'N/A',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final startOffset = _firstWeekdayOfMonth();
    final totalDays = _daysInMonth();

    final List<int?> cells = [
      ...List.filled(startOffset, null),
      ...List.generate(totalDays, (i) => i + 1),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final rowCells = cells.sublist(i, i + 7);
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: rowCells.map((day) {
              if (day == null) {
                return const Expanded(child: SizedBox(height: 34));
              }
              final isSelected = day == _selectedDay;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    height: 34,
                    alignment: Alignment.center,
                    decoration: isSelected
                        ? const BoxDecoration(
                      color: Color(0xFF1A4FBE),
                      shape: BoxShape.circle,
                    )
                        : null,
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

// ── Weekday Label ──────────────────────────────────────────────────────────
class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}

// ── Earnings Card ──────────────────────────────────────────────────────────
class _EarningsCard extends StatelessWidget {
  final String title;
  final String value;

  const _EarningsCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD0D9F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF888888),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
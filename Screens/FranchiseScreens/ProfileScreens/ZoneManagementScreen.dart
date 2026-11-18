// Screens/FranchiseScreens/ProfileScreens/ZoneManagementScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/Screens/FranchiseScreens/ProfileScreens/ZoneDetailScreen.dart';

class ZoneManagementScreen extends StatelessWidget {
  const ZoneManagementScreen({super.key});

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
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Zone Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: Column(
            children: [
              _ZoneCard(
                name: 'North Zone',
                color: AppColors.zoneNorth,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZoneDetailScreen(
                        zoneName: 'North Zone',
                        zoneColor: AppColors.zoneNorth,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ZoneCard(
                name: 'South Zone',
                color: AppColors.zoneSouth,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZoneDetailScreen(
                        zoneName: 'South Zone',
                        zoneColor: AppColors.zoneSouth,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ZoneCard(
                name: 'East Zone',
                color: AppColors.zoneEast,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZoneDetailScreen(
                        zoneName: 'East Zone',
                        zoneColor: AppColors.zoneEast,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ZoneCard(
                name: 'West Zone',
                color: AppColors.zoneWest,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZoneDetailScreen(
                        zoneName: 'West Zone',
                        zoneColor: AppColors.zoneWest,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback onTap;

  const _ZoneCard({
    required this.name,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            width: 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.001),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [

            const SizedBox(width: 14),

            // ── Name ──────────────────────────────────────────────────────
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),

            // ── Chevron (Greater Than) Icon ──────────────────────────────
            Icon(
              Icons.chevron_right,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
// Screens/FranchiseScreens/ProfileScreens/AddAreaScreen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/bloc/franchise_zone/franchise_zone_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_zone/franchise_zone_event.dart';
import 'package:jivit_jal_2/bloc/franchise_zone/franchise_zone_state.dart';

class AddAreaScreen extends StatefulWidget {
  final String zoneName;
  final String zoneKey;
  final Color zoneColor;

  const AddAreaScreen({
    super.key,
    required this.zoneName,
    required this.zoneKey,
    required this.zoneColor,
  });

  @override
  State<AddAreaScreen> createState() => _AddAreaScreenState();
}

class _AddAreaScreenState extends State<AddAreaScreen> {
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _fetchingLocation = false;
  String? _locationError;

  @override
  void dispose() {
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  bool get _canFetchLocation =>
      _cityCtrl.text.trim().isNotEmpty &&
      _stateCtrl.text.trim().isNotEmpty &&
      _pincodeCtrl.text.trim().length == 6;

  Future<void> _fetchLocation() async {
    final city = _cityCtrl.text.trim();
    final state = _stateCtrl.text.trim();
    final pincode = _pincodeCtrl.text.trim();

    setState(() {
      _fetchingLocation = true;
      _locationError = null;
      _latitude = null;
      _longitude = null;
    });

    try {
      // Try pincode first, then fallback to city+state
      final queries = [
        'postalcode=$pincode&country=India',
        'city=${Uri.encodeComponent(city)}&state=${Uri.encodeComponent(state)}&country=India',
      ];

      Map<String, dynamic>? result;

      for (final query in queries) {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?$query&format=json&limit=1',
        );
        final response = await http.get(uri, headers: {
          'User-Agent': 'JivitJalApp/1.0',
          'Accept-Language': 'en',
        });

        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          if (list.isNotEmpty) {
            result = list.first as Map<String, dynamic>;
            break;
          }
        }
      }

      if (result == null) {
        setState(() {
          _locationError = 'Location not found. Check city, state & pincode.';
          _fetchingLocation = false;
        });
        return;
      }

      setState(() {
        _latitude = double.tryParse(result!['lat'].toString());
        _longitude = double.tryParse(result['lon'].toString());
        _fetchingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Network error. Check your internet connection.';
        _fetchingLocation = false;
      });
    }
  }

  void _submit() {
    final city = _cityCtrl.text.trim();
    final state = _stateCtrl.text.trim();
    final pincodeStr = _pincodeCtrl.text.trim();

    if (city.isEmpty || state.isEmpty || pincodeStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    final pincode = int.tryParse(pincodeStr);
    if (pincode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid pincode'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please tap "Get Location" first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<FranchiseZoneBloc>().add(FranchiseZoneCityAddRequested(
      zone: widget.zoneKey,
      cityName: city,
      latitude: _latitude!,
      longitude: _longitude!,
      state: state,
      pincode: pincode,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return BlocConsumer<FranchiseZoneBloc, FranchiseZoneState>(
      listener: (context, state) {
        if (state is FranchiseZoneCityAddSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Area added successfully!')),
          );
          Navigator.pop(context);
        } else if (state is FranchiseZoneCityAddFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is FranchiseZoneCityAdding;

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
              title: Text(
                'Add Area · ${widget.zoneName}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── City Name ──────────────────────────────────────────
                  _buildField('City Name', _cityCtrl, 'e.g. Delhi',
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 16),

                  // ── State ──────────────────────────────────────────────
                  _buildField('State', _stateCtrl, 'e.g. Delhi',
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 16),

                  // ── Pincode ────────────────────────────────────────────
                  _buildField(
                    'Pincode',
                    _pincodeCtrl,
                    'e.g. 110001',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // ── Get Location Button ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: (_canFetchLocation && !_fetchingLocation) ? _fetchLocation : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _canFetchLocation ? AppColors.primaryBlue : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: _fetchingLocation
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                            )
                          : Icon(
                              _latitude != null ? Icons.location_on_rounded : Icons.my_location_rounded,
                              size: 18,
                              color: _canFetchLocation ? AppColors.primaryBlue : Colors.grey,
                            ),
                      label: Text(
                        _fetchingLocation
                            ? 'Fetching location...'
                            : _latitude != null
                                ? 'Location fetched ✓'
                                : 'Get Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _canFetchLocation ? AppColors.primaryBlue : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // ── Location Result / Error ────────────────────────────
                  if (_latitude != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Lat: ${_latitude!.toStringAsFixed(5)},  Lng: ${_longitude!.toStringAsFixed(5)}',
                            style: const TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_locationError != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_locationError!,
                                style: const TextStyle(fontSize: 12, color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // ── Submit Button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (isSaving || _fetchingLocation) ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_location_alt_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Add Area',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                              ],
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
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
          onChanged: onChanged,
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

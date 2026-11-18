import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  // Opens Google Maps turn-by-turn navigation from the rider's current
  // location to the given destination (lat/long, falling back to a text
  // address when coordinates aren't available — e.g. the rider order-list
  // API doesn't return lat/long, only the detail API does).
  static Future<void> openDirections({
    required BuildContext context,
    double? latitude,
    double? longitude,
    String? addressQuery,
  }) async {
    String destination;
    if (latitude != null && longitude != null && (latitude != 0 || longitude != 0)) {
      destination = '$latitude,$longitude';
    } else if (addressQuery != null && addressQuery.trim().isNotEmpty) {
      destination = addressQuery.trim();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location available'), backgroundColor: Colors.red),
      );
      return;
    }

    final origin = await _getCurrentOrigin(context);

    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
      'travelmode': 'driving',
      'dir_action': 'navigate',
      if (origin != null) 'origin': origin,
    });

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps'), backgroundColor: Colors.red),
      );
    }
  }

  // Best-effort fetch of the rider's current location as "lat,lng" for the
  // Maps "origin" param. Returns null (and just skips the origin param,
  // letting Google Maps fall back to its own current-location default) if
  // location services/permission aren't available.
  static Future<String?> _getCurrentOrigin(BuildContext context) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return '${position.latitude},${position.longitude}';
    } catch (_) {
      return null;
    }
  }
}

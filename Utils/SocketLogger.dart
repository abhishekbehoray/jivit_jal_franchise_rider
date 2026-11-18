import 'package:flutter/foundation.dart';

/// Pretty, boxed console logging for the live-tracking socket flow.
/// Matches the visual style of [ApiLogger] so socket + REST logs read the same.
/// All output is gated behind [kDebugMode] — nothing prints in release builds.
class SocketLogger {
  static const String _top =
      '┌───────────────────────────────────────────────────────────';
  static const String _sep =
      '├───────────────────────────────────────────────────────────';
  static const String _bottom =
      '└───────────────────────────────────────────────────────────';

  static String _timestamp() {
    final now = DateTime.now();
    String p2(int n) => n.toString().padLeft(2, '0');
    String p3(int n) => n.toString().padLeft(3, '0');
    return '${p2(now.hour)}:${p2(now.minute)}:${p2(now.second)}.${p3(now.millisecond)}';
  }

  /// Generic boxed event log. [fields] are rendered as an aligned key/value list.
  static void event(String emoji, String title, [Map<String, dynamic>? fields]) {
    if (!kDebugMode) return;
    debugPrint('\n$_top');
    debugPrint('│  $emoji  SOCKET · $title');
    debugPrint('│  🕒 ${_timestamp()}');
    if (fields != null && fields.isNotEmpty) {
      debugPrint(_sep);
      final pad = fields.keys
          .map((k) => k.length)
          .fold<int>(0, (m, l) => l > m ? l : m);
      fields.forEach((key, value) {
        debugPrint('│  ${key.padRight(pad)} : $value');
      });
    }
    debugPrint('$_bottom\n');
  }

  // ── Typed helpers (nice, self-documenting call sites) ───────────────────────
  static void connecting(String url) =>
      event('🔌', 'CONNECTING', {'url': url});

  static void connected() => event('🟢', 'CONNECTED');

  static void disconnected() => event('🔴', 'DISCONNECTED');

  static void connectError(Object err) =>
      event('⚠️', 'CONNECT ERROR', {'error': err});

  static void serverError(Object data) =>
      event('💥', 'SERVER ERROR', {'data': data});

  static void trackingStarted(String orderId, bool looksLikeMongoId) =>
      event('🛰️', 'TRACKING STARTED', {
        'orderId': orderId,
        'idLength': orderId.length,
        'mongoIdOk': looksLikeMongoId ? '✅ yes (24-hex)' : '❌ NO — not a 24-hex _id!',
      });

  static void joinOrder(String orderId) =>
      event('🚪', 'EMIT join_order', {'orderId': orderId});

  static void locationPing(
    int count,
    String orderId,
    double lat,
    double lng,
    double? accuracy,
  ) =>
      event('📍', 'EMIT update_location  (ping #$count)', {
        'orderId': orderId,
        'latitude': lat,
        'longitude': lng,
        if (accuracy != null) 'accuracy': '${accuracy.toStringAsFixed(1)} m',
      });

  static void locationSkipped(String reason) =>
      event('🚫', 'LOCATION SKIPPED', {'reason': reason});

  static void deliveryDone(String orderId) =>
      event('🏁', 'EMIT delivery_done', {'orderId': orderId});

  static void trackingStopped(int totalPings) =>
      event('🛑', 'TRACKING STOPPED', {'totalPingsSent': totalPings});
}

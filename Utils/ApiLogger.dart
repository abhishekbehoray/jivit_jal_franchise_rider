import 'package:flutter/foundation.dart';

class ApiLogger {
  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) {
    if (!kDebugMode) return;
    debugPrint('\n╔══════════════════════════════════════════════════════════');
    debugPrint('║  🚀 API REQUEST');
    debugPrint('╠══════════════════════════════════════════════════════════');
    debugPrint('║  [$method]  $url');
    if (headers != null) {
      debugPrint('║  Headers : $headers');
    }
    if (body != null) {
      debugPrint('║  Body    : $body');
    }
    debugPrint('╚══════════════════════════════════════════════════════════\n');
  }

  static void logResponse({
    required String url,
    required int statusCode,
    required String body,
  }) {
    if (!kDebugMode) return;
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final icon = isSuccess ? '✅' : '❌';
    debugPrint('\n╔══════════════════════════════════════════════════════════');
    debugPrint('║  $icon API RESPONSE');
    debugPrint('╠══════════════════════════════════════════════════════════');
    debugPrint('║  URL    : $url');
    debugPrint('║  Status : $statusCode');
    debugPrint('║  Body   : $body');
    debugPrint('╚══════════════════════════════════════════════════════════\n');
  }

  static void logError({
    required String url,
    required Object error,
  }) {
    if (!kDebugMode) return;
    debugPrint('\n╔══════════════════════════════════════════════════════════');
    debugPrint('║  💥 API ERROR');
    debugPrint('╠══════════════════════════════════════════════════════════');
    debugPrint('║  URL   : $url');
    debugPrint('║  Error : $error');
    debugPrint('╚══════════════════════════════════════════════════════════\n');
  }
}

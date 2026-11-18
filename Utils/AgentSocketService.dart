import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'ApiConstants.dart';
import 'SocketLogger.dart';

/// Live-location sender for the delivery agent (rider) app.
///
/// Flow (per backend integration guide):
///   1. When the rider marks an order "Out for Delivery" → [startDeliveryTracking]
///      connects the socket (authenticated with the rider's JWT), emits
///      `join_order`, then emits `update_location` every 30 seconds.
///   2. When the delivery is finished/failed → [stopDeliveryTracking] emits
///      `delivery_done`, stops the GPS loop and disconnects.
///
/// The `orderId` used here MUST be the DeliveryOrder's Mongo `_id` — in this app
/// that is the `deliveryOrderId` field carried through the rider order screens
/// (the value used as the REST resource key `/delivery-agent/orders/{id}`), NOT
/// the human-readable order number.
class AgentSocketService {
  AgentSocketService._internal();
  static final AgentSocketService _instance = AgentSocketService._internal();
  factory AgentSocketService() => _instance;

  io.Socket? _socket;
  Timer? _locationTimer;
  String? _activeOrderId;
  int _pingCount = 0;

  /// How often the rider's location is pushed while out for delivery.
  static const Duration _pingInterval = Duration(seconds: 30);

  bool get isTracking => _activeOrderId != null;
  String? get activeOrderId => _activeOrderId;

  // ── Connection ────────────────────────────────────────────────────────────
  Future<void> _ensureConnected() async {
    if (_socket != null && _socket!.connected) {
      SocketLogger.event('♻️', 'ALREADY CONNECTED', {
        'socketId': _socket!.id ?? '(pending)',
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    SocketLogger.connecting(ApiConstants.socketUrl);
    SocketLogger.event('🔑', 'AUTH', {
      'jwtPresent': token.isNotEmpty ? '✅ yes' : '❌ missing',
      'jwtPreview': token.isEmpty
          ? '(none)'
          : '${token.substring(0, token.length < 12 ? token.length : 12)}…',
    });

    // Reuse an existing (disconnected) socket, else build a fresh one.
    _socket ??= io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token}) // same JWT used for the REST API
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) => SocketLogger.connected())
      ..onDisconnect((_) => SocketLogger.disconnected())
      ..onConnectError((err) => SocketLogger.connectError(err))
      ..onError((err) => SocketLogger.serverError(err))
      ..on('error', (data) => SocketLogger.serverError(data));

    _socket!.connect();
  }

  // ── Start / stop tracking ───────────────────────────────────────────────────
  /// Call right after the REST call that sets status to `out_for_delivery`
  /// succeeds. Joins the order room and begins pushing location every 30s.
  Future<void> startDeliveryTracking(String orderId) async {
    if (orderId.isEmpty) {
      SocketLogger.event('❗', 'START ABORTED', {'reason': 'empty orderId'});
      return;
    }

    // Already tracking this exact order → nothing to do.
    if (_activeOrderId == orderId && _locationTimer != null) {
      SocketLogger.event('ℹ️', 'START IGNORED', {
        'reason': 'already tracking this order',
        'orderId': orderId,
      });
      return;
    }

    // Switching orders → clean up the previous session first.
    if (_activeOrderId != null && _activeOrderId != orderId) {
      SocketLogger.event('🔄', 'SWITCHING ORDER', {
        'from': _activeOrderId,
        'to': orderId,
      });
      _locationTimer?.cancel();
      _locationTimer = null;
    }

    _activeOrderId = orderId;
    _pingCount = 0;
    SocketLogger.trackingStarted(orderId, _looksLikeMongoId(orderId));

    await _ensureConnected();

    // Join the order room — the server validates the order belongs to this agent.
    SocketLogger.joinOrder(orderId);
    _socket?.emit('join_order', orderId);

    // Send one ping immediately, then every 30s.
    await _sendLocation();
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(_pingInterval, (_) => _sendLocation());
    SocketLogger.event('⏱️', 'PING TIMER STARTED', {
      'every': '${_pingInterval.inSeconds}s',
    });
  }

  /// Call when the delivery is completed or failed. Emits `delivery_done` so the
  /// user app can stop tracking, then stops the GPS loop and disconnects.
  void stopDeliveryTracking({bool emitDone = true}) {
    final orderId = _activeOrderId;
    if (orderId == null) {
      SocketLogger.event('ℹ️', 'STOP IGNORED', {'reason': 'nothing is being tracked'});
      return;
    }

    _locationTimer?.cancel();
    _locationTimer = null;

    if (emitDone && orderId.isNotEmpty) {
      SocketLogger.deliveryDone(orderId);
      _socket?.emit('delivery_done', orderId);
    }

    SocketLogger.trackingStopped(_pingCount);
    _activeOrderId = null;
    _socket?.disconnect();
  }

  // ── Location ping ───────────────────────────────────────────────────────────
  Future<void> _sendLocation() async {
    final orderId = _activeOrderId;
    if (orderId == null || orderId.isEmpty) return;

    final position = await _currentPosition();
    if (position == null) {
      SocketLogger.locationSkipped('GPS/permission unavailable');
      return;
    }

    _pingCount++;
    SocketLogger.locationPing(
      _pingCount,
      orderId,
      position.latitude,
      position.longitude,
      position.accuracy,
    );
    _socket?.emit('update_location', {
      'orderId': orderId,
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  Future<Position?> _currentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        SocketLogger.locationSkipped('location services are OFF');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        SocketLogger.locationSkipped('location permission denied ($permission)');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      SocketLogger.locationSkipped('exception: $e');
      return null;
    }
  }

  /// A Mongo ObjectId is 24 hex chars — a quick sanity check that we're sending
  /// the `_id` and not the human order number.
  bool _looksLikeMongoId(String id) =>
      RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id);
}

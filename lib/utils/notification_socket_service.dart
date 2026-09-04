import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class NotificationSocketService {
  late IO.Socket _socket;
  final int userId;
  final void Function(NotificationItem notification) onNotificationReceived;
  bool _isConnected = false;

  /// Whether the live channel is currently up.
  ///
  /// Exposed so the cubit can poll only as a fallback: while the socket is
  /// delivering, repeating the same question over HTTP every few seconds asks
  /// the server something it has already answered.
  bool get isConnected => _isConnected;

  NotificationSocketService({
    required this.userId,
    required this.onNotificationReceived,
  });

  void initialize() {
    _connectToSocket();
  }

  void _connectToSocket() {
    _socket = IO.io('https://socket.goalmasters.online', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    _socket.on('connect', (_) {
      print('✅ Connected to socket');
      if (!_isConnected) {
        _socket.emit('register', userId);
        _isConnected = true;
      }
    });

    _socket.on('notification', (data) {
      try {
        final notification = _mapSocketNotification(data);
        onNotificationReceived(notification);
      } catch (e) {
        print('❌ Error parsing notification: $e');
      }
    });

    _socket.on('disconnect', (_) {
      print('❌ Disconnected from socket');
      _isConnected = false;
    });

    _socket.on('connect_error', (err) {
      print('⚠️ Socket connection error: $err');
    });

    _socket.on('connect_timeout', (_) {
      print('⏰ Socket connection timeout');
    });
  }

  void dispose() {
    _socket.dispose();
  }

  NotificationItem _mapSocketNotification(dynamic rawData) {
    if (rawData is Map<String, dynamic> && rawData['data'] != null) {
      return NotificationItem.fromJson(rawData);
    }

    final payload = rawData is Map ? Map<String, dynamic>.from(rawData) : {};
    final dynamic messagePayload = payload['message'];
    final Map<String, dynamic> normalizedMessage =
        messagePayload is Map ? Map<String, dynamic>.from(messagePayload) : {};

    final messageText = normalizedMessage['message']?.toString() ??
        normalizedMessage['msg']?.toString() ??
        payload['msg']?.toString() ??
        payload['message']?.toString() ??
        '';

    final notificationId = normalizedMessage['id'] ?? payload['id'] ?? 0;
    final bookingId = normalizedMessage['booking_id'] ??
        payload['booking_id'] ??
        notificationId;
    final notificationType = normalizedMessage['type']?.toString() ??
        payload['type']?.toString() ??
        '';
    final notificationAmount = normalizedMessage['amount'] ?? payload['amount'];
    final notificationDescription =
        normalizedMessage['description']?.toString() ??
            payload['description']?.toString() ??
            '';

    return NotificationItem.fromJson({
      'id': 'socket_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'socket_notification',
      'notifiable_type': 'App.Models.User',
      'notifiable_id': userId,
      'data': {
        'id': notificationId,
        'booking_id': bookingId,
        'message': messageText,
        'type': notificationType,
        'amount': notificationAmount,
        'description': notificationDescription,
        'created_at': DateTime.now().toIso8601String(),
      },
      'read_at': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

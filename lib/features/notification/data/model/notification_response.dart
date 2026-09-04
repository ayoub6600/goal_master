import 'dart:convert';

/// ========= Helpers =========
bool asBool(dynamic v, {bool defaultValue = false}) {
  if (v == null) return defaultValue;
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  if (v is num) return v != 0;
  return defaultValue;
}

int asInt(dynamic v, {int defaultValue = 0}) {
  if (v == null) return defaultValue;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? defaultValue;
  return defaultValue;
}

double asDouble(dynamic v, {double defaultValue = 0.0}) {
  if (v == null) return defaultValue;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? defaultValue;
  return defaultValue;
}

String asString(dynamic v, {String defaultValue = ''}) {
  if (v == null) return defaultValue;
  return v.toString();
}

DateTime? asDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

List<T> asList<T>(dynamic v, T Function(dynamic) mapItem) {
  if (v is List) return v.map(mapItem).toList();
  return <T>[];
}

/// ========= Top-level converters =========
NotificationResponse notificationResponseFromJson(String str) =>
    NotificationResponse.fromJson(json.decode(str));

String notificationResponseToJson(NotificationResponse data) =>
    json.encode(data.toJson());

/// ========= Models =========
class NotificationResponse {
  final bool status;
  final NotificationData data;

  NotificationResponse({
    required this.status,
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        status: asBool(json['status']),
        data: NotificationData.fromJson(json['data'] ?? const {}),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data.toJson(),
      };
}

class NotificationData {
  final int currentPage;
  final List<NotificationItem> data;
  final String? firstPageUrl;
  final int? from; // قد تكون null لو القائمة فاضية
  final int lastPage;
  final String? lastPageUrl;
  final List<Link> links;
  final String? nextPageUrl; // قد تكون null
  final String path;
  final int perPage; // قد تأتي String من Laravel
  final String? prevPageUrl; // قد تكون null
  final int? to; // قد تكون null
  final int total;

  NotificationData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        currentPage: asInt(json['current_page']),
        data: asList(json['data'], (x) => NotificationItem.fromJson(x)),
        firstPageUrl: json['first_page_url'],
        from: json['from'] == null ? null : asInt(json['from']),
        lastPage: asInt(json['last_page']),
        lastPageUrl: json['last_page_url'],
        links: asList(json['links'], (x) => Link.fromJson(x)),
        nextPageUrl: json['next_page_url'],
        path: asString(json['path']),
        perPage: asInt(json['per_page']), // يقبل string/num
        prevPageUrl: json['prev_page_url'],
        to: json['to'] == null ? null : asInt(json['to']),
        total: asInt(json['total']),
      );

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'data': data.map((x) => x.toJson()).toList(),
        'first_page_url': firstPageUrl,
        'from': from,
        'last_page': lastPage,
        'last_page_url': lastPageUrl,
        'links': links.map((x) => x.toJson()).toList(),
        'next_page_url': nextPageUrl,
        'path': path,
        'per_page': perPage,
        'prev_page_url': prevPageUrl,
        'to': to,
        'total': total,
      };
}

class NotificationItem {
  final String id;
  final String type;
  final String notifiableType;
  final int notifiableId;
  final NotificationInnerData data;
  final String? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.notifiableType,
    required this.notifiableId,
    required this.data,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    // `data` في جدول notifications أحيانًا بتكون String JSON
    final dynamic rawData = json['data'];
    Map<String, dynamic> dataMap;
    if (rawData is String) {
      try {
        dataMap = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (_) {
        dataMap = <String, dynamic>{};
      }
    } else {
      dataMap = (rawData ?? {}) as Map<String, dynamic>;
    }

    return NotificationItem(
      id: asString(json['id']),
      type: asString(json['type']),
      notifiableType: asString(json['notifiable_type']),
      notifiableId: asInt(json['notifiable_id']),
      data: NotificationInnerData.fromJson(dataMap),
      readAt: json['read_at'],
      createdAt: asDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: asDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'notifiable_type': notifiableType,
        'notifiable_id': notifiableId,
        'data': data.toJson(),
        'read_at': readAt,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  NotificationItem copyWith({
    String? id,
    String? type,
    String? notifiableType,
    int? notifiableId,
    NotificationInnerData? data,
    String? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      notifiableType: notifiableType ?? this.notifiableType,
      notifiableId: notifiableId ?? this.notifiableId,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isRead => readAt != null;

  bool get isWalletTransaction {
    final rootType = type.toLowerCase();
    final dataType = data.type.toLowerCase();
    final messageText = data.message.toLowerCase();

    return rootType.contains('wallettransactionnotification') ||
        dataType.startsWith('wallet') ||
        messageText.contains('محفظ') ||
        messageText.contains('wallet');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class NotificationInnerData {
  final String message;
  final int id;
  final int bookingId;
  final String type;
  final double amount;
  final String description;
  final String createdAt;
  final String assistantName;
  final String assistantAvatar;

  NotificationInnerData({
    required this.message,
    required this.id,
    this.bookingId = 0,
    this.type = '',
    this.amount = 0.0,
    this.description = '',
    this.createdAt = '',
    this.assistantName = '',
    this.assistantAvatar = '',
  });

  factory NotificationInnerData.fromJson(Map<String, dynamic> json) =>
      NotificationInnerData(
        message: asString(json['message']),
        id: asInt(json['id']),
        bookingId: asInt(
          json['booking_id'],
          defaultValue: asInt(json['id']),
        ),
        type: asString(json['type']),
        amount: asDouble(json['amount']),
        description: asString(json['description']),
        createdAt: asString(json['created_at']),
        assistantName: asString(json['assistant_name']),
        assistantAvatar: asString(json['assistant_avatar']),
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'id': id,
        'booking_id': bookingId,
        'type': type,
        'amount': amount,
        'description': description,
        'created_at': createdAt,
        'assistant_name': assistantName,
        'assistant_avatar': assistantAvatar,
      };
}

class Link {
  final String? url;
  final String label;
  final bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json['url'],
        label: asString(json['label']),
        active: asBool(json['active']),
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'label': label,
        'active': active,
      };
}

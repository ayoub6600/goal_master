class TransactionsResponse {
  final bool status;
  final String message;
  final List<Transaction> data;
  final Summary summary;

  TransactionsResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.summary,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    final List<Transaction> txList = _parseTransactions(rawData);
    final Summary sum = _parseSummary(
      topLevelSummary: json['summary'],
      dataLevelSummary:
          (rawData is Map<String, dynamic>) ? rawData['summary'] : null,
    );

    return TransactionsResponse(
      status: _asBool(json['status']),
      message: (json['message'] ?? '').toString(),
      data: txList,
      summary: sum,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
        'summary': summary.toJson(),
      };

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      return s == 'true' || s == '1';
    }
    return false;
  }

  static List<Transaction> _parseTransactions(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Transaction.fromJson)
          .toList();
    }

    if (raw is Map<String, dynamic>) {
      final inner = raw['data'] ?? raw['transactions'] ?? raw['items'];

      if (inner is List) {
        return inner
            .whereType<Map<String, dynamic>>()
            .map(Transaction.fromJson)
            .toList();
      }

      final looksLikeTx = raw.containsKey('id') &&
          (raw.containsKey('amount') || raw.containsKey('balance_type'));
      if (looksLikeTx) {
        return [Transaction.fromJson(raw)];
      }
    }

    return <Transaction>[];
  }

  static Summary _parseSummary(
      {dynamic topLevelSummary, dynamic dataLevelSummary}) {
    if (topLevelSummary is Map<String, dynamic>) {
      return Summary.fromJson(topLevelSummary);
    }
    if (dataLevelSummary is Map<String, dynamic>) {
      return Summary.fromJson(dataLevelSummary);
    }
    return Summary(
      addedCount: 0,
      deductedCount: 0,
      totalAdded: 0,
      totalDeducted: 0,
      currentBalance: 0,
    );
  }
}

class Transaction {
  final int id;
  final String balanceableType;
  final int balanceableId;
  final double amount;
  final int userId;
  final int balanceType;
  final int status;
  final String? type;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TxUser? user;
  final TxUser? referenceUser;

  Transaction({
    required this.id,
    required this.balanceableType,
    required this.balanceableId,
    required this.amount,
    required this.userId,
    required this.balanceType,
    this.type,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.referenceUser,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: _asInt(json['id']),
      balanceableType: (json['balanceable_type'] ?? '').toString(),
      balanceableId: _asInt(json['balanceable_id']),
      type: (json['type'] ?? '').toString(),
      description: json['description']?.toString(),
      amount: _asDouble(json['amount']),
      userId: _asInt(json['user_id']),
      balanceType: _asInt(json['balance_type']),
      status: _asInt(json['status']),
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
      user: json['user'] is Map<String, dynamic>
          ? TxUser.fromJson(json['user'])
          : null,
      referenceUser: json['reference_user'] is Map<String, dynamic>
          ? TxUser.fromJson(json['reference_user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'balanceable_type': balanceableType,
        'balanceable_id': balanceableId,
        'amount': amount,
        'user_id': userId,
        'balance_type': balanceType,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'type': type,
        'description': description,
        'updated_at': updatedAt.toIso8601String(),
        'user': user?.toJson(),
        'reference_user': referenceUser?.toJson(),
      };

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static DateTime _asDate(dynamic v) {
    if (v == null) return DateTime.now();
    final s = v.toString();
    return DateTime.tryParse(s) ?? DateTime.now();
  }
}

class Summary {
  final int addedCount;
  final int deductedCount;
  final double totalAdded;
  final double totalDeducted;
  final double currentBalance;

  Summary({
    required this.addedCount,
    required this.deductedCount,
    required this.totalAdded,
    required this.totalDeducted,
    required this.currentBalance,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      addedCount: _asInt(json['added_count']),
      deductedCount: _asInt(json['deducted_count']),
      totalAdded: _asDouble(json['total_added']),
      totalDeducted: _asDouble(json['total_deducted']),
      currentBalance: _asDouble(json['current_balance']),
    );
  }

  Map<String, dynamic> toJson() => {
        'added_count': addedCount,
        'deducted_count': deductedCount,
        'total_added': totalAdded,
        'total_deducted': totalDeducted,
        'current_balance': currentBalance,
      };

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}

class TxUser {
  final int id;
  final String name;
  final String username;
  final String phoneNumber;
  final String? branchName;

  TxUser({
    required this.id,
    required this.name,
    required this.username,
    required this.phoneNumber,
    this.branchName,
  });

  factory TxUser.fromJson(Map<String, dynamic> json) {
    return TxUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      branchName: _asNullableString(
        json['branch_name'] ?? json['stadium_name'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'phone_number': phoneNumber,
        'branch_name': branchName,
      };

  static String? _asNullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

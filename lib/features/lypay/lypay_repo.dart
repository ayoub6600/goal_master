import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/dio_consumer.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/services/service_locator.dart';

/// The LYPay receiving account, as the admin set it.
class LypayAccount {
  const LypayAccount({
    required this.available,
    this.bankName,
    this.accountName,
    this.iban,
    this.accountNumber,
    this.minAmount = 10,
    this.maxAmount = 500,
    this.note,
  });

  final bool available;
  final String? bankName;
  final String? accountName;
  final String? iban;
  final String? accountNumber;
  final double minAmount;
  final double maxAmount;
  final String? note;

  factory LypayAccount.fromJson(Map<String, dynamic> json) => LypayAccount(
        available: json['available'] == true,
        bankName: _str(json['bank_name']),
        accountName: _str(json['account_name']),
        iban: _str(json['iban']),
        accountNumber: _str(json['account_number']),
        minAmount: _num(json['min_amount'], 10),
        maxAmount: _num(json['max_amount'], 500),
        note: _str(json['note']),
      );
}

/// One transfer the person reported.
class LypayRequest {
  const LypayRequest({
    required this.reference,
    required this.status,
    required this.statusLabel,
    required this.amountClaimed,
    this.amountCredited,
    this.rejectionReason,
  });

  final String reference;

  /// sent | checking | approved | rejected
  final String status;
  final String statusLabel;
  final double amountClaimed;
  final double? amountCredited;
  final String? rejectionReason;

  bool get isOpen => status == 'sent' || status == 'checking';

  factory LypayRequest.fromJson(Map<String, dynamic> json) => LypayRequest(
        reference: (json['reference'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        statusLabel: (json['status_label'] ?? '').toString(),
        amountClaimed: _num(json['amount_claimed'], 0),
        amountCredited:
            json['amount_credited'] == null ? null : _num(json['amount_credited'], 0),
        rejectionReason: _str(json['rejection_reason']),
      );
}

String? _str(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

double _num(dynamic v, double fallback) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? fallback;

/// LYPay top-ups. [basePath] is the wallet: `user/wallet/lypay` for the
/// customer, `manager/wallet/lypay` for the venue manager.
class LypayRepo {
  LypayRepo({this.basePath = 'user/wallet/lypay'});

  final String basePath;

  DioConsumer get _api => getIt<DioConsumer>();

  Future<Either<Failure, (LypayAccount, LypayRequest?)>> load() {
    return _api.handleRequest(
      () => _api.get(basePath),
      (json) {
        final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const {};
        final latest = data['latest'];
        return (
          LypayAccount.fromJson(
              (data['account'] as Map?)?.cast<String, dynamic>() ?? const {}),
          latest is Map ? LypayRequest.fromJson(latest.cast<String, dynamic>()) : null,
        );
      },
    );
  }

  Future<Either<Failure, LypayRequest>> submit({
    required double amount,
    required File receipt,
  }) {
    return _api.handleRequest(
      () async => _api.post(
        basePath,
        data: FormData.fromMap({
          'amount': amount.toString(),
          'receipt': await MultipartFile.fromFile(
            receipt.path,
            filename: receipt.path.split('/').last,
          ),
        }),
      ),
      (json) => LypayRequest.fromJson(
          (json['data'] as Map).cast<String, dynamic>()),
    );
  }

  Future<Either<Failure, LypayRequest>> status(String reference) {
    return _api.handleRequest(
      () => _api.get('$basePath/$reference'),
      (json) => LypayRequest.fromJson(
          (json['data'] as Map).cast<String, dynamic>()),
    );
  }
}

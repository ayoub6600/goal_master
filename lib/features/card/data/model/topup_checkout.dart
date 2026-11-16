/// A card top-up the server opened and signed.
///
/// Everything the Moamalat Lightbox needs comes from here — the app holds no
/// merchant key and picks neither the reference nor the amount it is
/// credited for.
class TopUpCheckout {
  const TopUpCheckout({
    required this.lightboxUrl,
    required this.mid,
    required this.tid,
    required this.amountTrxn,
    required this.merchantReference,
    required this.trxDateTime,
    required this.secureHash,
  });

  final String lightboxUrl;
  final String mid;
  final String tid;
  final String amountTrxn;
  final String merchantReference;
  final String trxDateTime;
  final String secureHash;

  factory TopUpCheckout.fromJson(Map<String, dynamic> json) {
    final c = Map<String, dynamic>.from(json['checkout'] as Map);
    String s(String k) => (c[k] ?? '').toString();
    return TopUpCheckout(
      lightboxUrl: s('lightbox_url'),
      mid: s('mid'),
      tid: s('tid'),
      amountTrxn: s('amount_trxn'),
      merchantReference: s('merchant_reference'),
      trxDateTime: s('trx_date_time'),
      secureHash: s('secure_hash'),
    );
  }
}

/// What the server decided after asking Moamalat.
class TopUpConfirmation {
  const TopUpConfirmation({required this.credited, required this.message});

  /// False means "paid, being confirmed": the money arrives on its own.
  final bool credited;
  final String message;

  factory TopUpConfirmation.fromJson(Map<String, dynamic> json) =>
      TopUpConfirmation(
        credited: json['topup_status']?.toString() == 'credited',
        message: (json['message'] ?? '').toString(),
      );
}

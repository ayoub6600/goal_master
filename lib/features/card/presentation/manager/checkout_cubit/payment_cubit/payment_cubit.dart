import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'payment_state.dart';

/// بدّل القيم من عندك
class Constant {
  static const mID = '10765981238';
  static const tID = '34152540';

  /// المفتاح بصيغة HEX (لو المزود عايز ASCII من HEX بدّل دالة المفتاح تحت)
  static const merchantKey = "effed1712b370f7d8011092861879bc7";
}

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  /// اختَر دومين واحد واثبت عليه
  final String _domain = 'https://npg.moamalat.net:6006';

  late int amountInMilli;
  late String merchantRef;

  Future<void> startPayment({
    required double amount, // بالجنيه مثلاً
    String? merchantRefOverride,
    bool useUtcTime = false, // لو المزود عايز توقيت UTC
  }) async {
    emit(PaymentLoading());
    try {
      merchantRef = merchantRefOverride ??
          'ORDER-${DateTime.now().millisecondsSinceEpoch}';
      amountInMilli = (amount * 1000).round(); // لو المزود عايز ×100 بدّلها

      final trxDateTime = _formatNowYYYYMMDDHHMMSS(useUtc: useUtcTime);

      final plain = 'Amount=$amountInMilli'
          '&DateTimeLocalTrxn=$trxDateTime'
          '&MerchantId=${Constant.mID}'
          '&MerchantReference=$merchantRef'
          '&TerminalId=${Constant.tID}';

      // لو المزود عايز ASCII من HEX استبدل _hexToBytes بـ _hexToAsciiBytes
      final keyBytes = _hexToBytes(Constant.merchantKey);
      final hmacHex = Hmac(sha256, keyBytes)
          .convert(utf8.encode(plain))
          .toString()
          .toUpperCase();

      final html = _buildPaymentHtml(
        domain: _domain,
        mid: Constant.mID,
        tid: Constant.tID,
        amountInMilli: amountInMilli,
        merchRef: merchantRef,
        trxDateTime: trxDateTime,
        secureHash: hmacHex,
      );

      emit(PaymentReady(html));
    } catch (e) {
      emit(PaymentError('Init failed: $e'));
    }
  }

  /// رسالة جاية من window.PaymentChannel.postMessage(...)
  void handleJsMessage(String message) {
    // تقدر توسّع بدعم JSON من الويب (شوف التعليق في HTML)
    switch (message) {
      case 'success':
        emit(const PaymentResult(status: PaymentResultStatus.completed));
        break;
      case 'error':
        emit(const PaymentResult(status: PaymentResultStatus.error));
        break;
      case 'cancel':
        emit(const PaymentResult(status: PaymentResultStatus.canceled));
        break;
      default:
        emit(PaymentError('Unknown message: $message'));
    }
  }

  // ——— Helpers ———
  String _formatNowYYYYMMDDHHMMSS({bool useUtc = false}) {
    final dt = useUtc ? DateTime.now().toUtc() : DateTime.now();
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${dt.year}${two(dt.month)}${two(dt.day)}'
        '${two(dt.hour)}${two(dt.minute)}${two(dt.second)}';
  }

  /// HEX -> bytes (مناسبة لمعظم المزودين)
  List<int> _hexToBytes(String hex) {
    final out = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      out.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return out;
  }

  /// لو الوثائق طالبة "ASCII from HEX" بدلاً من bytes مباشرة:
  /// استبدل استدعاء المفتاح بـ utf8.encode(_hexToAscii(hex))
  String _hexToAscii(String hex) {
    final buf = StringBuffer();
    for (var i = 0; i < hex.length; i += 2) {
      buf.write(
          String.fromCharCode(int.parse(hex.substring(i, i + 2), radix: 16)));
    }
    return buf.toString();
  }

  List<int> _hexToAsciiBytes(String hex) => utf8.encode(_hexToAscii(hex));

  String _buildPaymentHtml({
    required String domain,
    required String mid,
    required String tid,
    required int amountInMilli,
    required String merchRef,
    required String trxDateTime,
    required String secureHash,
  }) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Moamalat Payment</title>
  <script src="$domain/js/lightbox.js"></script>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; background: #f9f9f9; }
  </style>
</head>
<body>
  <h3>Processing Payment…</h3>
  <script>
    // لو حابب تستقبل داتا كاملة بدلاً من نص بسيط:
    // PaymentChannel.postMessage(JSON.stringify({status:'success', data:data}));
    window.onerror = function(msg, src, line, col, err) {
      if (window.PaymentChannel) PaymentChannel.postMessage('error');
    };

    function start() {
      Lightbox.Checkout.configure = {
        MID: '$mid',
        TID: '$tid',
        AmountTrxn: '$amountInMilli',
        MerchantReference: '$merchRef',
        TrxDateTime: '$trxDateTime',
        SecureHash: '$secureHash',
        showCloseButton: false,
        allowCancel: false,
        completeCallback: function (data) {
          if (window.PaymentChannel) PaymentChannel.postMessage('success');
        },
        errorCallback: function (data) {
          if (window.PaymentChannel) PaymentChannel.postMessage('error');
        },
        cancelCallback: function () {
          if (window.PaymentChannel) PaymentChannel.postMessage('cancel');
        }
      };
      Lightbox.Checkout.showLightbox();
    }
    window.onload = start;
  </script>
</body>
</html>
''';
  }
}

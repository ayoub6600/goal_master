import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/bottom_sheet/base_bottom_sheet.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/card/presentation/manager/add_transaction_cubit/add_transaction_cubit.dart';
import 'package:goal_master/features/saved_cards/presentation/saved_cards_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'card_fill_bridge.dart';
import 'card_fill_script.dart' show moamalatCardOrigins;
import 'payment_saved_card_panel.dart';

class PaymentScreen extends StatefulWidget {
  final String amount;

  const PaymentScreen({
    super.key,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController webViewController;
  late final String _merchantReference;
  bool isPageLoading = true;
  bool _resultHandled = false;
  bool _isLeaving = false;
  String? _webError;
  StreamSubscription<CardFillEvent>? _cardFillEvents;
  int? _cardFillWebViewId;
  bool _cardFillFormReady = false;
  bool _cardFillBridgeSupported = false;
  String _cardFillDiagnosticCode = 'BRIDGE_INITIALIZING';
  String? _cardFillDiagnosticDetail;
  Timer? _cardFillDiagnosticTimer;

  @override
  void initState() {
    super.initState();
    _merchantReference = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("PaymentChannel",
          onMessageReceived: (message) async {
        final raw = message.message;

        try {
          final data = jsonDecode(raw);
          final status = data["status"];

          if (status == "success") {
            _onSuccess();
          } else if (status == "error") {
            _showError("Payment failed: ${data["details"]}");
          } else if (status == "cancel") {
            _showError("Payment cancelled");
          } else {
            _showError("Unknown status: $raw");
          }
        } catch (_) {
          if (raw == "success") {
            _onSuccess();
          } else if (raw == "error") {
            _showError("Payment failed");
          } else if (raw == "cancel") {
            _showError("Payment cancelled");
          }
        }
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            isPageLoading = true;
            _webError = null;
          }),
          onPageFinished: (_) => setState(() => isPageLoading = false),
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                isPageLoading = false;
                _webError =
                    'تعذر تحميل صفحة الدفع. تحقق من الاتصال وحاول مرة ثانية.';
              });
            }
          },
        ),
      );
    unawaited(_startPaymentPage());
  }

  Future<void> _startPaymentPage() async {
    if (kDebugMode) {
      // Ensure the platform view has been created and registered before asking
      // the native plugin registry to resolve its WKWebView identifier.
      await WidgetsBinding.instance.endOfFrame;
      final platform = webViewController.platform;
      final id = platform is WebKitWebViewController
          ? platform.webViewIdentifier
          : platform is AndroidWebViewController
              ? platform.webViewIdentifier
              : null;
      if (id != null) {
        _cardFillWebViewId = id;
        _cardFillEvents = CardFillBridge.instance.events
            .where((event) => event.webViewId == id)
            .listen((event) {
          if (mounted) {
            setState(() {
              _cardFillFormReady = event.state == 'ready';
              _cardFillDiagnosticCode = event.state == 'ready'
                  ? 'FORM_DETECTED'
                  : 'FORM_NOT_DETECTED';
            });
          }
        });
        final install = await CardFillBridge.instance.install(id);
        if (mounted) {
          setState(() {
            _cardFillBridgeSupported = install.supported;
            _cardFillDiagnosticCode = install.diagnosticCode;
            _cardFillDiagnosticDetail = install.diagnosticDetail;
          });
        }
      } else if (mounted) {
        setState(() => _cardFillDiagnosticCode = 'WEBVIEW_ID_MISSING');
      }
    }
    if (mounted) {
      await webViewController.loadHtmlString(_buildPaymentHtml());
      if (kDebugMode) {
        _cardFillDiagnosticTimer?.cancel();
        _cardFillDiagnosticTimer = Timer(const Duration(seconds: 12), () {
          if (mounted && !_cardFillFormReady && _cardFillBridgeSupported) {
            unawaited(_diagnoseFrameOrigin());
          }
        });
      }
    }
  }

  Future<void> _diagnoseFrameOrigin() async {
    try {
      // Inspect only iframe src origins in this app-generated parent document;
      // never read or execute inside a child frame.
      final raw = await webViewController.runJavaScriptReturningResult('''
        JSON.stringify((() => {
          const expected = ${jsonEncode(moamalatCardOrigins)};
          const frames = Array.from(document.querySelectorAll('iframe'));
          const matched = frames.some(frame => {
            try { return expected.includes(new URL(frame.src, location.href).origin); }
            catch (_) { return false; }
          });
          return { count: frames.length, matched };
        })())
      ''');
      final decoded = jsonDecode(raw is String ? raw : '$raw');
      final mismatch = decoded is Map &&
          decoded['count'] is int &&
          decoded['count'] > 0 &&
          decoded['matched'] != true;
      if (mounted && !_cardFillFormReady) {
        setState(() => _cardFillDiagnosticCode =
            mismatch ? 'ORIGIN_MISMATCH' : 'FORM_NOT_DETECTED');
      }
    } catch (_) {
      if (mounted && !_cardFillFormReady) {
        setState(() => _cardFillDiagnosticCode = 'FORM_NOT_DETECTED');
      }
    }
  }

  String _currentCardOwner() {
    final userId = SharedPreferenceUtil.getInt(PrefKey.userId);
    return userId > 0 ? 'customer:$userId' : '';
  }

  @override
  void dispose() {
    _cardFillDiagnosticTimer?.cancel();
    _cardFillEvents?.cancel();
    final id = _cardFillWebViewId;
    if (id != null) unawaited(CardFillBridge.instance.dispose(id));
    super.dispose();
  }

  Future<void> _onSuccess() async {
    if (_resultHandled) return;
    _resultHandled = true;

    // 1. أرسل الطلب لحفظ المعاملة
    final cubit = context.read<AddTransactionBackEndCubit>();
    await cubit.addTransaction(
      widget.amount,
      "true",
      reference: _merchantReference,
    );

    if (!mounted) return;

    // 2. أظهر النتيجة في الـ Bottom Sheet
    final shouldReload = await baseBottomSheet(
      context: context,
      hideNavBar: true,
      showDragHandle: false,
      child: const PaymentResultSheet(success: true),
    );

    // 3. رجوع بعد العملية
    if (!mounted) return;
    Navigator.pop(context, shouldReload == true);
  }

  Future<void> _showError([String? title]) async {
    if (_resultHandled) return;
    _resultHandled = true;

    await baseBottomSheet(
      context: context,
      hideNavBar: true,
      showDragHandle: false,
      child: PaymentResultSheet(
        success: false,
        title: title ?? 'حدث خطأ أثناء الدفع',
        buttonText: 'حسناً',
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, false);
  }

  Future<void> _confirmExit() async {
    if (_isLeaving || !mounted) return;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إلغاء الدفع؟'),
          content: const Text(
            'إذا رجعت الآن فسيتم إلغاء عملية الدفع الحالية ولن يضاف أي رصيد.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('متابعة الدفع'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('نعم، رجوع'),
            ),
          ],
        );
      },
    );

    if (shouldLeave == true && mounted) {
      _isLeaving = true;
      Navigator.pop(context, false);
    }
  }

  Future<void> _manageSavedCards() async {
    final userId = SharedPreferenceUtil.getInt(PrefKey.userId);
    if (userId <= 0 || !mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SavedCardsPage(ownerId: 'customer:$userId'),
      ),
    );
  }

  String _buildPaymentHtml() {
    final mID = "10765981238";
    final tID = "34152540";
    final merchantKey = "effed1712b370f7d8011092861879bc7";
    final amount = double.tryParse(widget.amount) ?? 0.0;
    //  final amount = double.tryParse(widget.amount) ?? 0.0;

    final merchRef = _merchantReference;

    return """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Moamalat Payment</title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js"></script>
  <script src="https://npg.moamalat.net:6006/js/lightbox.js"></script>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; background: #f9f9f9; }
  </style>
</head>
<body>
  <h3>Processing Payment...</h3>
  <script>
    function callLightbox() {
      var mID = '$mID';
      var tID = '$tID';
      var amount = $amount;
      var merchRef = '$merchRef';

      var merchantKey = "$merchantKey";
      var keyBytes = CryptoJS.enc.Hex.parse(merchantKey);
      var dt = new Date().YYYYMMDDHHMMSS();

      var strToHash = 'Amount=' + amount + '000' +
                      '&DateTimeLocalTrxn=' + dt +
                      '&MerchantId=' + mID +
                      '&MerchantReference=' + merchRef +
                      '&TerminalId=' + tID;

      var secureHash = CryptoJS.HmacSHA256(strToHash, keyBytes)
                               .toString(CryptoJS.enc.Hex)
                               .toUpperCase();

      Lightbox.Checkout.configure = {
        MID: mID,
        TID: tID,
        AmountTrxn: amount + '000',
        MerchantReference: merchRef,
        TrxDateTime: dt,
        SecureHash: secureHash,
        showCloseButton: true,
        allowCancel: true,

        completeCallback: function (data) {
          console.log('Payment complete:', data);
          PaymentChannel.postMessage("success");
        },
     errorCallback: function (data) {
  console.error('Payment error:', data);
  PaymentChannel.postMessage(JSON.stringify({
    status: "error",
    details: data
  }));
},
        cancelCallback: function () {
          console.warn('Payment cancelled');
          PaymentChannel.postMessage("cancel");
        }
      };

      Lightbox.Checkout.showLightbox();
    }

    Object.defineProperty(Date.prototype, 'YYYYMMDDHHMMSS', {
      value: function () {
        function pad2(n) { return (n < 10 ? '0' : '') + n; }
        return this.getFullYear().toString() +
          pad2(this.getMonth() + 1) +
          pad2(this.getDate()) +
          pad2(this.getHours()) +
          pad2(this.getMinutes()) +
          pad2(this.getSeconds());
      }
    });

    window.onload = function() {
      callLightbox();
    };
  </script>
</body>
</html>
""";
  }

  @override
  Widget build(BuildContext context) {
    final userId = SharedPreferenceUtil.getInt(PrefKey.userId);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmExit();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _confirmExit,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text('الدفع بالكرت'),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (kDebugMode && userId > 0)
                PaymentSavedCardPanel(
                  ownerId: 'customer:$userId',
                  currentOwnerId: _currentCardOwner,
                  webViewId: _cardFillWebViewId,
                  formReady: _cardFillFormReady,
                  bridgeSupported: _cardFillBridgeSupported,
                  diagnosticCode: _cardFillDiagnosticCode,
                  diagnosticDetail: _cardFillDiagnosticDetail,
                  onManageCards: _manageSavedCards,
                ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // The Lightbox content is provider-owned (often an iframe).
                    // Flutter can only guarantee the native WebView bounds here.
                    WebViewWidget(controller: webViewController),
                    if (isPageLoading)
                      const ColoredBox(
                        color: Color(0x33FFFFFF),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_webError != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_webError!, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    onPressed: () => webViewController.reload(),
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentResultSheet extends StatelessWidget {
  const PaymentResultSheet({
    super.key,
    required this.success,
    this.title,
    this.buttonText,
    this.onDone,
  });

  final bool success;
  final String? title;
  final String? buttonText;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final isSuccess = success;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isSuccess ? const Color(0xFFE6F7EA) : const Color(0xFFFFECEB),
              border: Border.all(
                color: isSuccess
                    ? const Color(0xFF2EB872)
                    : const Color(0xFFE74C3C),
                width: 2,
              ),
            ),
            child: Icon(
              isSuccess ? Icons.check_rounded : Icons.close_rounded,
              size: 56,
              color:
                  isSuccess ? const Color(0xFF2EB872) : const Color(0xFFE74C3C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title ?? (isSuccess ? 'تم الدفع بنجاح' : 'فشل الدفع'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                onDone?.call();
                Navigator.of(context).pop(isSuccess); // يرجّع true لو نجاح
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: isSuccess
                    ? const Color(0xFF2EB872)
                    : const Color(0xFFE74C3C),
                foregroundColor: const Color(0xFFFFFFFF),
              ),
              child: Text(buttonText ?? 'تم'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

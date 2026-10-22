import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../saved_cards/data/card_vault.dart';
import '../../../../saved_cards/data/saved_card.dart';
import 'card_fill_bridge.dart';

class PaymentSavedCardPanel extends StatefulWidget {
  const PaymentSavedCardPanel(
      {super.key,
      required this.ownerId,
      required this.currentOwnerId,
      required this.webViewId,
      required this.formReady,
      required this.bridgeSupported,
      required this.diagnosticCode,
      this.diagnosticDetail,
      @visibleForTesting this.vaultStore,
      required this.onManageCards});
  final String ownerId;
  final String Function() currentOwnerId;
  final int? webViewId;
  final bool formReady;
  final bool bridgeSupported;
  final String diagnosticCode;
  final String? diagnosticDetail;
  @visibleForTesting
  final SecretStore? vaultStore;
  final Future<void> Function() onManageCards;

  @override
  State<PaymentSavedCardPanel> createState() => _PaymentSavedCardPanelState();
}

class _PaymentSavedCardPanelState extends State<PaymentSavedCardPanel>
    with WidgetsBindingObserver {
  List<SavedCardSummary> _cards = const [];
  int _selected = 0;
  bool _loading = true, _agreedToTerms = false, _filling = false;
  String? _status;
  String? _fillDiagnosticCode;
  bool _copying = false;
  String? _lastCopiedValue;
  Timer? _clipboardCleanupTimer;

  CardVault _vault(String owner) => CardVault(
      store: widget.vaultStore ?? const SecureStorageSecretStore(),
      ownerId: owner);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      final value = _lastCopiedValue;
      if (value != null) unawaited(_clearClipboardIfUnchanged(value));
    }
  }

  @override
  void didUpdateWidget(covariant PaymentSavedCardPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) {
      _agreedToTerms = false;
      _status = null;
      _loading = true;
      _load();
    }
  }

  Future<void> _load() async {
    final owner = widget.ownerId;
    final cards = await _vault(owner).loadSummaries();
    if (!mounted || widget.ownerId != owner) return;
    setState(() {
      _cards = cards;
      _selected = 0;
      _loading = false;
    });
  }

  Future<void> _manage() async {
    await widget.onManageCards();
    if (mounted) await _load();
  }

  Future<void> _copySelected(_CardCopyField field) async {
    if (!kDebugMode || _copying || _loading || _cards.isEmpty) return;
    final index = _selected.clamp(0, _cards.length - 1);
    final cardId = _cards[index].id;
    final owner = widget.currentOwnerId();
    if (owner != widget.ownerId || !owner.startsWith('customer:')) {
      setState(() => _status = 'تغير الحساب الحالي؛ أعد فتح صفحة الدفع.');
      return;
    }
    setState(() {
      _copying = true;
      _status = null;
    });
    try {
      var card = await _vault(owner).byId(cardId);
      if (card == null ||
          widget.currentOwnerId() != owner ||
          !mounted ||
          _selected != index ||
          _cards[_selected.clamp(0, _cards.length - 1)].id != cardId) {
        if (mounted) {
          setState(
              () => _status = 'تعذر العثور على البطاقة المحددة لهذا الحساب.');
        }
        return;
      }

      final value = switch (field) {
        _CardCopyField.number => card.number,
        _CardCopyField.expiry => card.expiryText,
        _CardCopyField.name => card.holderName.trim(),
      };
      if (value.isEmpty) {
        setState(() => _status = 'تعذر نسخ بيانات البطاقة المحددة.');
        return;
      }
      await Clipboard.setData(ClipboardData(text: value));
      _lastCopiedValue = value;
      _clipboardCleanupTimer?.cancel();
      _clipboardCleanupTimer = Timer(const Duration(seconds: 30),
          () => unawaited(_clearClipboardIfUnchanged(value)));
      if (field == _CardCopyField.number) {
        try {
          await CardFillBridge.instance.markClipboardSensitive(value);
        } catch (_) {
          // Clipboard sensitivity is best-effort on supported Android versions.
        }
      }
      card = null;
      if (mounted) {
        setState(() => _status = switch (field) {
              _CardCopyField.number => 'تم نسخ رقم البطاقة',
              _CardCopyField.expiry => 'تم نسخ التاريخ',
              _CardCopyField.name => 'تم نسخ الاسم',
            });
      }
    } catch (_) {
      if (mounted) setState(() => _status = 'تعذر نسخ بيانات البطاقة.');
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  Future<void> _clearClipboardIfUnchanged(String expected) async {
    if (_lastCopiedValue != expected) return;
    try {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      if (current?.text == expected) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (_) {
      // Clipboard cleanup is best-effort; the OS may deny clipboard access.
    } finally {
      if (_lastCopiedValue == expected) _lastCopiedValue = null;
      _clipboardCleanupTimer?.cancel();
      _clipboardCleanupTimer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clipboardCleanupTimer?.cancel();
    final value = _lastCopiedValue;
    if (value != null) unawaited(_clearClipboardIfUnchanged(value));
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await showModalBottomSheet<int>(
        context: context,
        builder: (context) => SafeArea(
                child: ListView(children: [
              const ListTile(title: Text('تغيير البطاقة')),
              for (var index = 0; index < _cards.length; index++)
                ListTile(
                  leading: const Icon(Icons.credit_card_outlined),
                  title: Text(_cards[index].masked),
                  subtitle: Text(
                      '${_cards[index].holderName} • ${_cards[index].expiryText}'),
                  trailing: index == _selected
                      ? const Icon(Icons.check, color: Color(0xff16874e))
                      : null,
                  onTap: () => Navigator.pop(context, index),
                ),
            ])));
    if (picked != null && mounted) {
      setState(() {
        _selected = picked;
        _status = null;
      });
    }
  }

  Future<void> _fill() async {
    if (!kDebugMode ||
        _filling ||
        !widget.formReady ||
        !_agreedToTerms ||
        _cards.isEmpty ||
        widget.webViewId == null) {
      return;
    }
    final cardId = _cards[_selected.clamp(0, _cards.length - 1)].id;
    final owner = widget.currentOwnerId();
    if (owner != widget.ownerId || !owner.startsWith('customer:')) {
      setState(() {
        _fillDiagnosticCode = 'CARD_NOT_FOUND';
        _status = 'تغير الحساب الحالي؛ أعد فتح صفحة الدفع.';
      });
      return;
    }
    setState(() {
      _filling = true;
      _status = null;
      _fillDiagnosticCode = null;
    });
    try {
      var card = await _vault(owner).byId(cardId);
      if (card == null ||
          widget.currentOwnerId() != owner ||
          !mounted ||
          _cards[_selected.clamp(0, _cards.length - 1)].id != cardId) {
        if (mounted) {
          setState(() {
            _fillDiagnosticCode = 'CARD_NOT_FOUND';
            _status = 'تعذر العثور على البطاقة المحددة لهذا الحساب.';
          });
        }
        return;
      }
      final result = await CardFillBridge.instance.fill(
          id: widget.webViewId!,
          pan: card.number,
          expiry: card.expiryText,
          name: card.holderName,
          acceptTerms: true);
      card = null;
      if (!mounted) return;
      setState(() {
        _fillDiagnosticCode = result.diagnosticCode;
        _status = result.ok
            ? (result.terms == 'checked'
                ? 'تمت تعبئة البطاقة ومربع شروط الدفع. راجع البيانات ثم أكمل بنفسك.'
                : 'تمت تعبئة البطاقة، ولم يُعثر على مربع شروط الدفع؛ راجعه يدويًا.')
            : 'التعبئة التلقائية غير متاحة حاليًا. تقدر تنسخ بيانات بطاقتك وتلصقها يدويًا.';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _fillDiagnosticCode = 'FILL_FAILED';
          _status =
              'التعبئة التلقائية غير متاحة حاليًا. تقدر تنسخ بيانات بطاقتك وتلصقها يدويًا.';
        });
      }
    } finally {
      if (mounted) setState(() => _filling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    if (_loading) {
      return const Padding(
          padding: EdgeInsets.all(16), child: LinearProgressIndicator());
    }
    if (_cards.isEmpty) {
      return _Frame(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('بطاقتك المحفوظة',
            style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('ما عندكش بطاقات محفوظة على هذا الجهاز.'),
        Text('التشخيص: ${widget.diagnosticCode}',
            key: const Key('card-fill-diagnostic')),
        const SizedBox(height: 10),
        OutlinedButton.icon(
            onPressed: _manage,
            icon: const Icon(Icons.add),
            label: const Text('إضافة بطاقة جديدة')),
      ]));
    }
    final card = _cards[_selected.clamp(0, _cards.length - 1)];
    return _Frame(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('بطاقتك المحفوظة',
          style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.credit_card, color: Color(0xff16874e)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${card.brand} • ${card.masked}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Text('${card.holderName} • ${card.expiryText}')
        ]))
      ]),
      Wrap(spacing: 8, runSpacing: 4, children: [
        OutlinedButton.icon(
          key: const Key('copy-card-number'),
          onPressed:
              _copying ? null : () => _copySelected(_CardCopyField.number),
          icon: const Icon(Icons.content_copy, size: 16),
          label: const Text('نسخ رقم البطاقة'),
        ),
        OutlinedButton.icon(
          key: const Key('copy-card-expiry'),
          onPressed:
              _copying ? null : () => _copySelected(_CardCopyField.expiry),
          icon: const Icon(Icons.content_copy, size: 16),
          label: const Text('نسخ تاريخ الانتهاء'),
        ),
        OutlinedButton.icon(
          key: const Key('copy-card-name'),
          onPressed: _copying ? null : () => _copySelected(_CardCopyField.name),
          icon: const Icon(Icons.content_copy, size: 16),
          label: const Text('نسخ الاسم'),
        ),
      ]),
      const Text(
          'سيُحاول التطبيق مسح الحافظة بعد 30 ثانية؛ قد تحتفظ بعض الأجهزة بسجل الحافظة.',
          style: TextStyle(fontSize: 10, color: Colors.black54)),
      CheckboxListTile(
          key: const Key('payment-terms-consent'),
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: _agreedToTerms,
          onChanged: (value) => setState(() {
                _agreedToTerms = value == true;
                _status = null;
              }),
          title: const Text(
              'راجعت شروط الدفع الظاهرة في صفحة مواملات وأوافق عليها.',
              style: TextStyle(fontSize: 12))),
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton(onPressed: _pick, child: const Text('تغيير البطاقة')),
        OutlinedButton(
            onPressed: widget.bridgeSupported &&
                    widget.formReady &&
                    _agreedToTerms &&
                    !_filling
                ? _fill
                : null,
            child: _filling
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('تعبئة البيانات')),
        TextButton(onPressed: _manage, child: const Text('إضافة بطاقة جديدة')),
      ]),
      Text('التشخيص: ${_fillDiagnosticCode ?? widget.diagnosticCode}',
          key: const Key('card-fill-diagnostic'),
          style: const TextStyle(fontSize: 11, color: Colors.black54)),
      if (widget.diagnosticDetail != null)
        Text(widget.diagnosticDetail!,
            key: const Key('card-fill-diagnostic-detail'),
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
      Text(
          !widget.bridgeSupported
              ? 'التعبئة التلقائية غير متاحة حاليًا. تقدر تنسخ بيانات بطاقتك وتلصقها يدويًا.'
              : widget.formReady
                  ? 'ستُعبأ البطاقة المحددة بعد ضغط الزر. CVV لن يُلمس، ولن يتم الضغط على زر الدفع.'
                  : 'بانتظار اكتشاف نموذج البطاقة الآمن داخل صفحة الدفع.',
          style: const TextStyle(fontSize: 11, color: Colors.black54)),
      if (_status != null)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_status!,
                key: const Key('card-fill-status'),
                style: const TextStyle(fontSize: 12))),
    ]));
  }
}

enum _CardCopyField { number, expiry, name }

class _Frame extends StatelessWidget {
  const _Frame({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xfff4fbf6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffb9dfc7))),
      child: Material(color: Colors.transparent, child: child));
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/card_vault.dart';
import '../data/saved_card.dart';
import 'card_camera_scan_page.dart';
import 'card_scan_review_page.dart';

class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({
    super.key,
    required this.ownerId,
  });

  final String ownerId;

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage> {
  late final CardVault _vault;
  List<SavedCard> _cards = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    if (widget.ownerId.trim().isEmpty) {
      _loading = false;
      _error = 'تعذر تحديد حساب المستخدم';
      return;
    }

    _vault = CardVault(
      store: const SecureStorageSecretStore(),
      ownerId: widget.ownerId,
    );

    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cards = await _vault.load();

      if (!mounted) return;

      setState(() {
        _cards = cards;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'تعذر تحميل البطاقات';
      });
    }
  }

  Future<void> _openForm([SavedCard? existing]) async {
    final draft = await Navigator.of(context).push<_CardDraft>(
      MaterialPageRoute(
        builder: (_) => _CardFormPage(existing: existing),
      ),
    );

    if (!mounted || draft == null) return;

    try {
      if (existing == null) {
        await _vault.add(
          holderName: draft.holder,
          number: draft.number!,
          expMonth: draft.month,
          expYear: draft.year,
          nickname: draft.nickname,
        );
      } else {
        await _vault.update(
          existing.id,
          holderName: draft.holder,
          number: draft.number,
          expMonth: draft.month,
          expYear: draft.year,
          nickname: draft.nickname,
        );
      }

      if (mounted) await _reload();
    } catch (_) {
      if (!mounted) return;
      _showError('تعذر حفظ البطاقة');
    }
  }

  Future<void> _makeDefault(SavedCard card) async {
    try {
      await _vault.setDefault(card.id);
      if (mounted) await _reload();
    } catch (_) {
      if (mounted) _showError('تعذر تغيير البطاقة الافتراضية');
    }
  }

  Future<void> _delete(SavedCard card) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف البطاقة؟'),
        content: Text('هل تبي تحذف البطاقة ${card.masked}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (approved != true || !mounted) return;

    try {
      await _vault.delete(card.id);
      if (mounted) await _reload();
    } catch (_) {
      if (mounted) _showError('تعذر حذف البطاقة');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بطاقاتي المحفوظة'),
      ),
      floatingActionButton: widget.ownerId.trim().isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('إضافة بطاقة'),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _cards.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'ما عندكش بطاقات محفوظة.\n'
                          'اضغط إضافة بطاقة للبدء.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Text(
                            'البطاقات محفوظة على هذا الجهاز فقط. '
                            'رمز CVV لا يتم حفظه.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        for (final card in _cards)
                          Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(
                                Icons.credit_card,
                                size: 30,
                              ),
                              title: Text(
                                card.nickname?.isNotEmpty == true
                                    ? card.nickname!
                                    : card.masked,
                              ),
                              subtitle: Text(
                                '${card.masked}\n'
                                '${card.holderName} • '
                                '${card.expiryText}'
                                '${card.isDefault ? "\nالبطاقة الافتراضية" : ""}',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (action) {
                                  switch (action) {
                                    case 'default':
                                      _makeDefault(card);
                                    case 'edit':
                                      _openForm(card);
                                    case 'delete':
                                      _delete(card);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'default',
                                    child: Text('تعيين كافتراضية'),
                                  ),
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('تعديل'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('حذف'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }
}

class _CardDraft {
  const _CardDraft({
    required this.holder,
    required this.number,
    required this.month,
    required this.year,
    required this.nickname,
  });

  final String holder;
  final String? number;
  final int month;
  final int year;
  final String nickname;
}

class _CardFormPage extends StatefulWidget {
  const _CardFormPage({this.existing});

  final SavedCard? existing;

  @override
  State<_CardFormPage> createState() => _CardFormPageState();
}

class _CardFormPageState extends State<_CardFormPage> {
  late final TextEditingController _holder;
  late final TextEditingController _number;
  late final TextEditingController _expiry;
  late final TextEditingController _nickname;

  String? _error;

  @override
  void initState() {
    super.initState();

    _holder = TextEditingController(
      text: widget.existing?.holderName ?? '',
    );

    _number = TextEditingController();

    _expiry = TextEditingController(
      text: widget.existing?.expiryText ?? '',
    );

    _nickname = TextEditingController(
      text: widget.existing?.nickname ?? '',
    );
  }

  @override
  void dispose() {
    _holder.dispose();
    _number.dispose();
    _expiry.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final scanned = await Navigator.of(context).push<CardScanReviewResult>(
      MaterialPageRoute(
        builder: (_) => const CardCameraScanPage(),
      ),
    );

    if (!mounted || scanned == null) return;

    setState(() {
      _holder.text = scanned.holderName;
      _number.text = CardRules.groupNumber(scanned.number);
      _expiry.text = scanned.expiryText;
      _error = null;
    });
  }

  void _save() {
    final holder = _holder.text.trim();
    final enteredNumber = CardRules.digitsOnly(_number.text);
    final expiryText = _expiry.text.trim();

    if (holder.length < 2) {
      setState(() => _error = 'راجع اسم صاحب البطاقة');
      return;
    }

    final mustValidateNumber =
        widget.existing == null || enteredNumber.isNotEmpty;

    if (mustValidateNumber &&
        (enteredNumber.length < 13 ||
            enteredNumber.length > 19 ||
            !CardRules.luhnValid(enteredNumber))) {
      setState(() => _error = 'رقم البطاقة غير صحيح');
      return;
    }

    if (!CardRules.isExpiryValid(expiryText)) {
      setState(() => _error = 'تاريخ انتهاء البطاقة غير صحيح');
      return;
    }

    final expiry = CardRules.parseExpiry(expiryText);

    if (expiry == null) {
      setState(() => _error = 'راجع تاريخ الانتهاء');
      return;
    }

    Navigator.of(context).pop(
      _CardDraft(
        holder: holder,
        number: enteredNumber.isEmpty ? null : enteredNumber,
        month: expiry.month,
        year: expiry.year,
        nickname: _nickname.text.trim(),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    bool ltr = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatters,
        textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const <String>[],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'تعديل البطاقة' : 'إضافة بطاقة'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.credit_card,
              size: 65,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('تصوير البطاقة بالكاميرا'),
            ),
            const SizedBox(height: 24),
            _input(
              'اسم صاحب البطاقة',
              _holder,
              keyboard: TextInputType.name,
            ),
            _input(
              editing ? 'رقم جديد للبطاقة (اختياري)' : 'رقم البطاقة',
              _number,
              keyboard: TextInputType.number,
              ltr: true,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                LengthLimitingTextInputFormatter(23),
              ],
            ),
            _input(
              'تاريخ الانتهاء MM/YY',
              _expiry,
              keyboard: TextInputType.datetime,
              ltr: true,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                LengthLimitingTextInputFormatter(5),
              ],
            ),
            _input(
              'اسم مختصر للبطاقة (اختياري)',
              _nickname,
            ),
            const SizedBox(height: 4),
            const Text(
              'رمز CVV تكتبه في صفحة الدفع فقط. '
              'ما نطلبوهش وما نحفظوهش هنا.',
              textAlign: TextAlign.center,
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('حفظ البطاقة'),
            ),
          ],
        ),
      ),
    );
  }
}

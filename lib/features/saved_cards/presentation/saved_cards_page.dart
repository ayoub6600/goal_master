import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/card_vault.dart';
import '../data/saved_card.dart';
import 'card_camera_scan_page.dart';
import 'card_scan_review_page.dart';
import 'package:goal_master/core/components/skeletons.dart';

class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({
    super.key,
    required this.ownerId,
    this.embedded = false,
  });

  final String ownerId;
  final bool embedded;

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
    final draft = await showModalBottomSheet<_CardDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CardFormPage(existing: existing, embedded: true),
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
    final content = _buildCards();
    if (widget.embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: content,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('بطاقاتي المحفوظة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: content,
      ),
    );
  }

  Widget _buildCards() {
    if (_loading) {
      return const Skeleton(
        child: SkeletonBox(height: 170, width: double.infinity, radius: 20),
      );
    }
    if (_error != null) {
      return SizedBox(
        height: 100,
        child: Center(child: Text(_error!, textAlign: TextAlign.center)),
      );
    }

    final canAdd = widget.ownerId.trim().isNotEmpty;

    if (_cards.isEmpty) {
      return _EmptyCards(onAdd: canAdd ? () => _openForm() : null);
    }

    // The default card first, then the rest in the order they were added.
    final cards = [..._cards]
      ..sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final card in cards)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CardVisual(
              holder: card.holderName,
              masked: card.masked,
              expiry: card.expiryText,
              nickname: card.nickname,
              brand: _brandOf(card.number),
              isDefault: card.isDefault,
              menu: PopupMenuButton<String>(
                tooltip: 'خيارات',
                icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
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
                itemBuilder: (_) => [
                  if (!card.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: _MenuRow(
                          Icons.star_outline_rounded, 'تعيين كبطاقة افتراضية'),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: _MenuRow(Icons.edit_outlined, 'تعديل'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: _MenuRow(Icons.delete_outline_rounded, 'حذف',
                        color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        if (canAdd) _AddCardButton(onTap: () => _openForm()),
        const SizedBox(height: 12),
        const _PrivacyNote(),
      ],
    );
  }
}

/// "VISA" / "Mastercard" from the number's first digit, or nothing.
String? _brandOf(String number) {
  final digits = CardRules.digitsOnly(number);
  if (digits.isEmpty) return null;
  if (digits.startsWith('4')) return 'VISA';
  if (digits.startsWith('5') || digits.startsWith('2')) return 'Mastercard';
  return null;
}

const Color _cardGreen = Color(0xFF418946);
const Color _cardGreenDark = Color(0xFF24552A);

/// A saved card drawn as a card: number, holder, expiry and brand, with the
/// default one in the brand green and the others in slate.
class _CardVisual extends StatelessWidget {
  const _CardVisual({
    required this.holder,
    required this.masked,
    required this.expiry,
    this.nickname,
    this.brand,
    this.isDefault = false,
    this.showBadge = true,
    this.menu,
  });

  final String holder;
  final String masked;
  final String expiry;
  final String? nickname;
  final String? brand;
  final bool isDefault;

  /// Off for the live preview in the form: a card being typed is not
  /// "افتراضية" yet.
  final bool showBadge;
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    final colors = isDefault
        ? const [_cardGreen, _cardGreenDark]
        : const [Color(0xFF4A5868), Color(0xFF2C3642)];
    final label =
        (nickname?.trim().isNotEmpty ?? false) ? nickname!.trim() : null;

    return AspectRatio(
      aspectRatio: 1.75,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 6, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isDefault && showBadge)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('افتراضية',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else if (label != null)
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                const Spacer(),
                if (menu != null) menu! else const SizedBox(height: 40),
              ],
            ),
            const Spacer(),
            // The chip.
            Container(
              width: 34,
              height: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8D28B), Color(0xFFC9A94F)],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                masked.replaceAll('*', '•'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        holder.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      expiry,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (brand != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        brand!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label, {this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

class _AddCardButton extends StatelessWidget {
  const _AddCardButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F8F3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFD9BF), width: 1.2),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_card_rounded, color: _cardGreen),
              SizedBox(width: 8),
              Text(
                'إضافة بطاقة جديدة',
                style: TextStyle(
                  color: _cardGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCards extends StatelessWidget {
  const _EmptyCards({this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF5EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.credit_card_rounded,
                color: _cardGreen, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            'ما عندكش بطاقات محفوظة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'احفظ بطاقتك مرة وحدة، وادفع أسرع في المرات الجاية.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6D7580)),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _cardGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('إضافة بطاقة',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
          const SizedBox(height: 14),
          const _PrivacyNote(),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF6D7580)),
        SizedBox(width: 4),
        Flexible(
          child: Text(
            'محفوظة على هذا الجهاز فقط، ورمز CVV لا يُحفظ أبدًا.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF6D7580)),
          ),
        ),
      ],
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
  const _CardFormPage({this.existing, this.embedded = false});

  final SavedCard? existing;
  final bool embedded;

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

    // The card preview at the top follows what is typed.
    for (final c in [_holder, _number, _expiry, _nickname]) {
      c.addListener(_onTyped);
    }
  }

  void _onTyped() {
    if (mounted) setState(() {});
  }

  /// The number as it would print on the card: typed digits, the rest dots.
  String get _previewNumber {
    final digits = CardRules.digitsOnly(_number.text);
    if (digits.isEmpty) {
      return widget.existing?.masked ?? '•••• •••• •••• ••••';
    }
    final padded = digits.padRight(16, '•');
    final groups = <String>[];
    for (var i = 0; i < padded.length; i += 4) {
      groups.add(
          padded.substring(i, i + 4 > padded.length ? padded.length : i + 4));
    }
    return groups.join(' ');
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
    IconData? icon,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
          hintText: hint,
          prefixIcon: icon == null
              ? null
              : Icon(icon, color: const Color(0xFF6D7580), size: 20),
          filled: true,
          fillColor: const Color(0xFFF7F9F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE1E8E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE1E8E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _cardGreen, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final holder = _holder.text.trim();
    final expiry = _expiry.text.trim();

    final form = SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: widget.embedded,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          _CardVisual(
            holder: holder.isEmpty ? 'اسم صاحب البطاقة' : holder,
            masked: _previewNumber,
            expiry: expiry.isEmpty ? 'MM/YY' : expiry,
            nickname: _nickname.text,
            brand: _brandOf(_number.text.isEmpty
                ? (widget.existing?.number ?? '')
                : _number.text),
            isDefault: true,
            showBadge: false,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _cardGreen,
              side: const BorderSide(color: Color(0xFFBFD9BF)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _scan,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('صوّر البطاقة وتعبّى البيانات تلقائيًا',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 18),
          _input(
            editing ? 'رقم جديد للبطاقة (اختياري)' : 'رقم البطاقة',
            _number,
            keyboard: TextInputType.number,
            ltr: true,
            icon: Icons.credit_card_rounded,
            formatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
              LengthLimitingTextInputFormatter(23),
            ],
          ),
          _input(
            'اسم صاحب البطاقة',
            _holder,
            keyboard: TextInputType.name,
            icon: Icons.person_outline_rounded,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _input(
                  'الانتهاء',
                  _expiry,
                  keyboard: TextInputType.datetime,
                  ltr: true,
                  hint: 'MM/YY',
                  icon: Icons.event_outlined,
                  formatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                    LengthLimitingTextInputFormatter(5),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _input(
                  'اسم للبطاقة',
                  _nickname,
                  hint: 'اختياري',
                  icon: Icons.label_outline_rounded,
                ),
              ),
            ],
          ),
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _cardGreen,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(editing ? 'حفظ التعديلات' : 'حفظ البطاقة',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          const _PrivacyNote(),
        ],
      ),
    );
    if (widget.embedded) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      editing ? 'تعديل البطاقة' : 'إضافة بطاقة',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(child: form),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'تعديل البطاقة' : 'إضافة بطاقة')),
      body: form,
    );
  }
}

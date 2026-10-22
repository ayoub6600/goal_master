import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/card_text_parser.dart';
import '../data/saved_card.dart';

class CardScanReviewResult {
  const CardScanReviewResult({
    required this.holderName,
    required this.number,
    required this.expiryText,
  });

  final String holderName;
  final String number;
  final String expiryText;
}

class CardScanReviewPage extends StatefulWidget {
  const CardScanReviewPage({
    super.key,
    required this.scanned,
  });

  final ScannedCard scanned;

  @override
  State<CardScanReviewPage> createState() => _CardScanReviewPageState();
}

class _CardScanReviewPageState extends State<CardScanReviewPage> {
  late final TextEditingController _holder;
  late final TextEditingController _number;
  late final TextEditingController _expiry;

  String? _error;

  @override
  void initState() {
    super.initState();

    _holder = TextEditingController(
      text: widget.scanned.holder ?? '',
    );

    _number = TextEditingController(
      text: widget.scanned.number == null
          ? ''
          : CardRules.groupNumber(widget.scanned.number!),
    );

    _expiry = TextEditingController(
      text: widget.scanned.expiryText ?? '',
    );
  }

  @override
  void dispose() {
    _holder.dispose();
    _number.dispose();
    _expiry.dispose();
    super.dispose();
  }

  void _confirm() {
    final holder = _holder.text.trim();
    final digits = CardRules.digitsOnly(_number.text);
    final expiry = _expiry.text.trim();

    if (holder.length < 2) {
      setState(() => _error = 'تأكد من اسم صاحب البطاقة');
      return;
    }

    if (digits.length < 13 ||
        digits.length > 19 ||
        !CardRules.luhnValid(digits)) {
      setState(() => _error = 'رقم البطاقة غير صحيح، راجعه من فضلك');
      return;
    }

    if (!CardRules.isExpiryValid(expiry)) {
      setState(() => _error = 'تاريخ انتهاء البطاقة غير صحيح');
      return;
    }

    Navigator.of(context).pop(
      CardScanReviewResult(
        holderName: holder,
        number: digits,
        expiryText: expiry,
      ),
    );
  }

  Widget _field({
    required String title,
    required TextEditingController controller,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    bool leftToRight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatters,
        textDirection: leftToRight ? TextDirection.ltr : TextDirection.rtl,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const <String>[],
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.scanned.review;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة بيانات البطاقة'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.credit_card,
                size: 65,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              const Text(
                'راجع البيانات قبل المتابعة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'البيانات قُريت من صورة البطاقة على جهازك. '
                'تأكد من صحتها وعدّل أي خطأ.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (review.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'بعض البيانات مش واضحة بالكامل. '
                    'راجع الرقم والاسم وتاريخ الانتهاء بعناية.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _field(
                title: 'اسم صاحب البطاقة',
                controller: _holder,
                keyboard: TextInputType.name,
              ),
              _field(
                title: 'رقم البطاقة',
                controller: _number,
                keyboard: TextInputType.number,
                leftToRight: true,
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9 ]'),
                  ),
                  LengthLimitingTextInputFormatter(23),
                ],
              ),
              _field(
                title: 'تاريخ الانتهاء MM/YY',
                controller: _expiry,
                keyboard: TextInputType.datetime,
                leftToRight: true,
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9/]'),
                  ),
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                'لن نطلب رمز CVV ولن نحفظ صورة البطاقة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('تأكيد البيانات'),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('إعادة التصوير'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

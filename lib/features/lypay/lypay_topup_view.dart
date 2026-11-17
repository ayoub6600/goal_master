import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';

import 'lypay_repo.dart';
import 'package:goal_master/core/components/skeletons.dart';

const Color _green = Color(0xFF418946);
const Color _greenDark = Color(0xFF24552A);
const Color _grey = Color(0xFF6D7580);

/// «تحويل LYPay»: transfer from your bank app to the account shown, attach
/// the receipt, and the wallet is credited after an admin checks it.
///
/// Shows the open request instead of the form while one is being reviewed —
/// one at a time, the same rule the server enforces.
class LypayTopUpView extends StatefulWidget {
  const LypayTopUpView({
    super.key,
    this.repo,
    this.onApproved,
  });

  /// `LypayRepo()` for the customer wallet; the manager app passes its own.
  final LypayRepo? repo;

  /// Called when a request the person is looking at turns out approved.
  final VoidCallback? onApproved;

  @override
  State<LypayTopUpView> createState() => _LypayTopUpViewState();
}

class _LypayTopUpViewState extends State<LypayTopUpView> {
  late final LypayRepo _repo = widget.repo ?? LypayRepo();
  final _amount = TextEditingController();

  bool _loading = true;
  bool _sending = false;
  String? _error;
  LypayAccount? _account;
  LypayRequest? _request;
  File? _receipt;

  /// After a rejected or approved request the form comes back.
  bool _showForm = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repo.load();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.errMessage;
      }),
      (value) {
        final (account, latest) = value;
        setState(() {
          _loading = false;
          _account = account;
          _request = latest;
          _showForm = latest == null || !latest.isOpen;
        });
      },
    );
  }

  Future<void> _refreshStatus() async {
    final current = _request;
    if (current == null) return;
    final result = await _repo.status(current.reference);
    if (!mounted) return;
    result.fold(
      (failure) => _toast(failure.errMessage),
      (fresh) {
        setState(() => _request = fresh);
        if (fresh.status == 'approved' && current.status != 'approved') {
          widget.onApproved?.call();
        }
      },
    );
  }

  Future<void> _pickReceipt() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 88,
    );
    if (picked != null && mounted) {
      setState(() => _receipt = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final account = _account;
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    if (account == null) return;
    if (amount < account.minAmount) {
      _toast('أقل مبلغ ${_money(account.minAmount)} د.ل');
      return;
    }
    if (amount > account.maxAmount) {
      _toast('أقصى مبلغ ${_money(account.maxAmount)} د.ل');
      return;
    }
    final receipt = _receipt;
    if (receipt == null) {
      _toast('أرفق صورة إيصال التحويل');
      return;
    }

    setState(() => _sending = true);
    final result = await _repo.submit(amount: amount, receipt: receipt);
    if (!mounted) return;
    setState(() => _sending = false);
    result.fold(
      (failure) {
        _toast(failure.errMessage);
        // An open request already exists: show it.
        _load();
      },
      (request) => setState(() {
        _request = request;
        _showForm = false;
        _receipt = null;
        _amount.clear();
      }),
    );
  }

  /// Above the sheet: a SnackBar would sit under it, unseen.
  void _toast(String message) => showCustomFailureToast(message);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
          height: 220, child: SkeletonList(count: 4, shrinkWrap: true));
    }
    if (_error != null) {
      return _Message(
        icon: Icons.wifi_off_rounded,
        text: _error!,
        action: TextButton(onPressed: _load, child: const Text('إعادة المحاولة')),
      );
    }
    final account = _account!;
    if (!account.available) {
      return const _Message(
        icon: Icons.account_balance_outlined,
        text: 'الشحن بالتحويل عبر LYPay غير متاح حاليًا.',
      );
    }

    final request = _request;
    if (!_showForm && request != null) {
      return _RequestStatus(
        request: request,
        onRefresh: _refreshStatus,
        onNew: request.isOpen ? null : () => setState(() => _showForm = true),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (request != null && request.status == 'rejected')
          _Banner(
            color: const Color(0xFFFDECEC),
            icon: Icons.info_outline_rounded,
            iconColor: Colors.red,
            text:
                'طلبك السابق (${request.reference}) مرفوض: ${request.rejectionReason ?? ''}',
          ),
        const _Step(number: 1, text: 'حوّل المبلغ من تطبيق مصرفك عبر LYPay إلى:'),
        const SizedBox(height: 8),
        _AccountCard(account: account),
        if (account.note != null) ...[
          const SizedBox(height: 8),
          _Banner(
            color: const Color(0xFFFFF8E8),
            icon: Icons.lightbulb_outline_rounded,
            iconColor: const Color(0xFFB7791F),
            text: account.note!,
          ),
        ],
        const SizedBox(height: 16),
        const _Step(number: 2, text: 'اكتب المبلغ الذي حوّلته:'),
        const SizedBox(height: 8),
        TextField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          decoration: _decoration(
            'من ${_money(account.minAmount)} إلى ${_money(account.maxAmount)} د.ل',
          ).copyWith(suffixText: 'د.ل'),
        ),
        const SizedBox(height: 16),
        const _Step(number: 3, text: 'أرفق صورة إيصال التحويل:'),
        const SizedBox(height: 8),
        _ReceiptPicker(file: _receipt, onTap: _pickReceipt),
        const SizedBox(height: 18),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _sending ? null : _submit,
          child: _sending
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: Colors.white))
              : const Text('إرسال للمراجعة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 10),
        const Text(
          'نراجع التحويل ونشحن محفظتك بعد التأكد من وصوله، ويصلك إشعار بالنتيجة.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: _grey),
        ),
      ],
    );
  }
}

InputDecoration _decoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: _grey),
      filled: true,
      fillColor: const Color(0xFFF7F9F7),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
    );

String _money(double v) {
  final s = v.toStringAsFixed(2);
  return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
          child: Text('$number',
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final LypayAccount account;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String?, bool)>[
      ('المصرف', account.bankName, false),
      ('اسم الحساب', account.accountName, false),
      ('IBAN', account.iban, true),
      ('رقم الحساب', account.accountNumber, true),
    ].where((r) => r.$2 != null).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_green, _greenDark],
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            _CopyRow(label: rows[i].$1, value: rows[i].$2!, ltr: rows[i].$3),
          ],
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
        ),
        Expanded(
          // An IBAN is 25 characters: shrunk to one line rather than broken
          // across two, where it is easy to copy by hand wrongly.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              textDirection: ltr ? TextDirection.ltr : null,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        IconButton(
          tooltip: 'نسخ',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: value));
            showCustomSuccessToast('تم نسخ $label');
          },
        ),
      ],
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  const _ReceiptPicker({required this.file, required this.onTap});

  final File? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final picked = file;
    return Material(
      color: const Color(0xFFF3F8F3),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: picked == null ? 96 : 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFD9BF), width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: picked == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: _green, size: 30),
                    SizedBox(height: 6),
                    Text('اختر صورة الإيصال',
                        style: TextStyle(
                            color: _green, fontWeight: FontWeight.w700)),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(picked, fit: BoxFit.cover, cacheWidth: 600),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: const Text('اضغط لتغيير الصورة',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RequestStatus extends StatelessWidget {
  const _RequestStatus({
    required this.request,
    required this.onRefresh,
    this.onNew,
  });

  final LypayRequest request;
  final Future<void> Function() onRefresh;
  final VoidCallback? onNew;

  @override
  Widget build(BuildContext context) {
    final (color, icon, title) = switch (request.status) {
      'approved' => (_green, Icons.check_circle_rounded, 'تم شحن محفظتك'),
      'rejected' => (Colors.red, Icons.cancel_rounded, 'لم يتم قبول التحويل'),
      'checking' => (const Color(0xFF2F80ED), Icons.manage_search_rounded, 'جاري التحقق من التحويل'),
      _ => (const Color(0xFFE08A1E), Icons.hourglass_top_rounded, 'طلبك قيد المراجعة'),
    };
    final amount = request.amountCredited ?? request.amountClaimed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9F7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _InfoRow('رقم الطلب', request.reference, ltr: true),
              _InfoRow('المبلغ', '${_money(amount)} د.ل'),
              _InfoRow('الحالة', request.statusLabel),
              if (request.rejectionReason != null)
                _InfoRow('السبب', request.rejectionReason!),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (request.isOpen)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _green,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('تحديث الحالة'),
          ),
        if (onNew != null)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: onNew,
            child: const Text('تحويل جديد'),
          ),
        const SizedBox(height: 8),
        if (request.isOpen)
          const Text(
            'يصلك إشعار عند المراجعة. عادةً خلال ساعات العمل.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _grey),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: _grey)),
          ),
          Expanded(
            child: Text(
              value,
              textDirection: ltr ? TextDirection.ltr : null,
              textAlign: ltr ? TextAlign.right : TextAlign.start,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _grey, size: 36),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center),
          if (action != null) action!,
        ],
      ),
    );
  }
}

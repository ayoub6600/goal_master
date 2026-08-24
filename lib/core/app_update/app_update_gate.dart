import 'package:flutter/material.dart';
import 'package:goal_master/core/app_update/app_update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({
    super.key,
    required this.child,
    required this.appKey,
  });

  final Widget child;
  final String appKey;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  bool _checked = false;
  bool _dismissedOptional = false;
  AppUpdateDecision? _decision;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  Future<void> _checkUpdate() async {
    final decision = await AppUpdateService().check(appKey: widget.appKey);
    if (!mounted) return;
    setState(() => _decision = decision);
  }

  Future<void> _openStore(String? url) async {
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('رابط التحديث غير متوفر حالياً')),
      );
      return;
    }
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('رابط التحديث غير صحيح')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _dismissOptional() {
    setState(() => _dismissedOptional = true);
  }

  bool get _shouldShowUpdate {
    final decision = _decision;
    if (decision == null || !decision.updateRequired) return false;
    if (decision.force) return true;
    return !_dismissedOptional;
  }

  @override
  Widget build(BuildContext context) {
    final decision = _decision;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_shouldShowUpdate && decision != null)
          _AppUpdateOverlay(
            decision: decision,
            onUpdateNow: () => _openStore(decision.storeUrl),
            onLater: decision.force ? null : _dismissOptional,
          ),
      ],
    );
  }
}

class _AppUpdateOverlay extends StatelessWidget {
  const _AppUpdateOverlay({
    required this.decision,
    required this.onUpdateNow,
    required this.onLater,
  });

  final AppUpdateDecision decision;
  final VoidCallback onUpdateNow;
  final VoidCallback? onLater;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      decision.force
                          ? Icons.system_update_alt
                          : Icons.new_releases_outlined,
                      color: const Color(0xFF2F8B45),
                      size: 44,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      decision.title ?? 'تحديث جديد متوفر',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      decision.message ??
                          'يوجد إصدار جديد من Goal Master. يرجى تحديث التطبيق.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(height: 1.6),
                    ),
                    if ((decision.deadlineAt ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'آخر موعد للتحديث: ${decision.deadlineAt}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF9A5B00),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if ((decision.releaseNotes ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8F4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          decision.releaseNotes!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onUpdateNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F8B45),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('تحديث الآن'),
                    ),
                    if (onLater != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: onLater,
                        child: const Text('لاحقًا'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

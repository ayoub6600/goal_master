import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/support/support_repo.dart';
import 'package:image_picker/image_picker.dart';

/// Customer service chat with the Goal Master team: text, photos, reply to a
/// message, take back your own message. Polls every few seconds while open
/// (a push brings the person here when the screen is closed).
class SupportChatView extends StatefulWidget {
  const SupportChatView({super.key, SupportRepo? repo})
      : _repo = repo;

  final SupportRepo? _repo;

  static VoidCallback? _openRefresh;

  /// A reply arrived by push: an open thread fetches it at once and says
  /// true (so no banner is shown over it); otherwise false.
  static bool refreshIfOpen() {
    final refresh = _openRefresh;
    if (refresh == null) return false;
    refresh();
    return true;
  }

  @override
  State<SupportChatView> createState() => _SupportChatViewState();
}

class _Pending {
  _Pending(this.uuid, this.body, this.image, this.replyToId, this.replyPreview);
  final String uuid;
  final String? body;
  final File? image;
  final int? replyToId;
  final String? replyPreview;
  bool failed = false;
}

class _SupportChatViewState extends State<SupportChatView>
    with WidgetsBindingObserver {
  late final SupportRepo _repo = widget._repo ?? SupportRepo();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final Map<int, SupportMessage> _byId = {};
  final List<_Pending> _pending = [];

  Timer? _poll;
  bool _loading = true;
  bool _loadingOlder = false;
  bool _hasOlder = false;
  bool _handoff = false;
  bool _fetching = false;
  String? _error;
  SupportMessage? _replyTo;
  File? _image;

  static const _pollEvery = Duration(seconds: 4);

  List<SupportMessage> get _messages =>
      _byId.values.toList()..sort((a, b) => a.id.compareTo(b.id));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SupportChatView._openRefresh = _refresh;
    _refresh(first: true);
    _poll = Timer.periodic(_pollEvery, (_) => _refresh());
    _scroll.addListener(_onScroll);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // No polling while the app is in the background.
    if (state == AppLifecycleState.resumed) {
      _poll ??= Timer.periodic(_pollEvery, (_) => _refresh());
      _refresh();
    } else if (state == AppLifecycleState.paused) {
      _poll?.cancel();
      _poll = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (SupportChatView._openRefresh == _refresh) {
      SupportChatView._openRefresh = null;
    }
    _poll?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _atBottom =>
      !_scroll.hasClients ||
      _scroll.position.pixels >= _scroll.position.maxScrollExtent - 120;

  void _toBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      animate
          ? _scroll.animateTo(end,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut)
          : _scroll.jumpTo(end);
    });
  }

  /// The latest page, merged by id: new messages, admins' reads (✓✓) and
  /// deletions all show up.
  Future<void> _refresh({bool first = false}) async {
    if (_fetching) return;
    _fetching = true;
    final stick = _atBottom;
    final before = _byId.isEmpty ? 0 : _messages.last.id;
    final result = await _repo.messages();
    _fetching = false;
    if (!mounted) return;
    result.fold(
      (f) {
        if (first) {
          setState(() {
            _loading = false;
            _error = f.errMessage;
          });
        }
      },
      (r) {
        final (list, handoff) = r;
        setState(() {
          for (final m in list) {
            _byId[m.id] = m;
          }
          if (first) _hasOlder = list.length >= 60;
          _handoff = handoff;
          _loading = false;
          _error = null;
        });
        final after = _byId.isEmpty ? 0 : _messages.last.id;
        if (first) {
          _toBottom(animate: false);
        } else if (after > before && stick) {
          _toBottom();
        }
      },
    );
  }

  void _onScroll() {
    if (_scroll.position.pixels <= 80) _loadOlder();
  }

  Future<void> _loadOlder() async {
    if (!_hasOlder || _loadingOlder || _byId.isEmpty) return;
    setState(() => _loadingOlder = true);
    final oldHeight = _scroll.position.maxScrollExtent;
    final result = await _repo.messages(beforeId: _messages.first.id);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingOlder = false),
      (r) {
        setState(() {
          for (final m in r.$1) {
            _byId[m.id] = m;
          }
          _hasOlder = r.$1.length >= 60;
          _loadingOlder = false;
        });
        // Keep the reader where they were.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scroll.hasClients) return;
          _scroll.jumpTo(_scroll.position.pixels +
              (_scroll.position.maxScrollExtent - oldHeight));
        });
      },
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked != null && mounted) setState(() => _image = File(picked.path));
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty && _image == null) return;
    final p = _Pending(
      SupportRepo.newClientUuid(),
      text.isEmpty ? null : text,
      _image,
      _replyTo?.id,
      _replyTo == null ? null : _previewOf(_replyTo!),
    );
    setState(() {
      _pending.add(p);
      _controller.clear();
      _image = null;
      _replyTo = null;
    });
    _toBottom();
    _deliver(p);
  }

  Future<void> _deliver(_Pending p) async {
    if (p.failed) setState(() => p.failed = false);
    final result = await _repo.send(
      body: p.body,
      image: p.image,
      replyToId: p.replyToId,
      clientUuid: p.uuid,
    );
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() => p.failed = true);
        showCustomFailureToast(f.errMessage);
      },
      (m) {
        setState(() {
          _pending.remove(p);
          _byId[m.id] = m;
        });
        _toBottom();
      },
    );
  }

  String _previewOf(SupportMessage m) =>
      m.body ?? (m.imageUrl != null ? '📷 صورة' : '');

  Future<void> _actions(SupportMessage m) async {
    if (m.isSystem || m.deleted) return;
    HapticFeedback.selectionClick();
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('رد على الرسالة'),
              onTap: () => Navigator.pop(ctx, 'reply'),
            ),
            if (m.body != null)
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('نسخ النص'),
                onTap: () => Navigator.pop(ctx, 'copy'),
              ),
            if (m.mine)
              ListTile(
                leading: Icon(Icons.delete_outline_rounded,
                    color: AppColors.errorRed),
                title: Text('حذف الرسالة',
                    style: TextStyle(color: AppColors.errorRed)),
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'reply':
        setState(() => _replyTo = m);
      case 'copy':
        await Clipboard.setData(ClipboardData(text: m.body ?? ''));
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف الرسالة؟'),
            content: const Text('ستُحذف الرسالة عندك وعند خدمة العملاء.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('حذف',
                      style: TextStyle(color: AppColors.errorRed))),
            ],
          ),
        );
        if (ok != true || !mounted) return;
        final result = await _repo.delete(m.id);
        if (!mounted) return;
        result.fold((f) => showCustomFailureToast(f.errMessage), (_) {
          setState(() => _byId[m.id] = SupportMessage(
                id: m.id,
                fromAdmin: m.fromAdmin,
                isSystem: false,
                deleted: true,
                read: m.read,
                createdAt: m.createdAt,
              ));
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F2),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.support_agent_rounded, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('خدمة عملاء Goal Master',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                    _handoff
                        ? 'تم تحويلك — سيرد عليك موظف قريبًا'
                        : 'نحن هنا لمساعدتك',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _byId.isEmpty
                    ? _ErrorState(
                        message: _error!,
                        onRetry: () {
                          setState(() => _loading = true);
                          _refresh(first: true);
                        })
                    : items.isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                            itemCount: items.length + (_loadingOlder ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (_loadingOlder) {
                                if (i == 0) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Center(
                                        child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2))),
                                  );
                                }
                                i--;
                              }
                              return items[i];
                            },
                          ),
          ),
          _composer(),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    final out = <Widget>[];
    DateTime? lastDay;
    for (final m in _messages) {
      final d = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
      if (lastDay == null || d != lastDay) {
        lastDay = d;
        out.add(_DaySeparator(label: _dayLabel(d)));
      }
      out.add(m.isSystem
          ? _SystemNote(text: m.body ?? '')
          : _Bubble(
              key: ValueKey('m${m.id}'),
              message: m,
              onLongPress: () => _actions(m),
              onSwipeReply: m.deleted ? null : () => setState(() => _replyTo = m),
            ));
    }
    for (final p in _pending) {
      out.add(_PendingBubble(pending: p, onRetry: () => _deliver(p)));
    }
    return out;
  }

  Widget _composer() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyTo != null)
              _ComposerBanner(
                icon: Icons.reply_rounded,
                text: _previewOf(_replyTo!),
                onClose: () => setState(() => _replyTo = null),
              ),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_image!,
                          width: 64, height: 64, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('صورة جاهزة للإرسال')),
                    IconButton(
                      onPressed: () => setState(() => _image = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _pickImage,
                    tooltip: 'إرفاق صورة',
                    icon: Icon(Icons.image_outlined, color: AppColors.primary),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 2000,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك…',
                        counterText: '',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF1F4F0),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _send,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        // RTL: the arrow points the way the text goes.
                        child: Icon(Icons.send_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _two(int n) => n.toString().padLeft(2, '0');

String _time(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${_two(t.minute)} ${t.hour < 12 ? 'ص' : 'م'}';
}

String _dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'اليوم';
  if (diff == 1) return 'أمس';
  return '${d.day}/${d.month}/${d.year}';
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.message,
    required this.onLongPress,
    this.onSwipeReply,
  });

  final SupportMessage message;
  final VoidCallback onLongPress;
  final VoidCallback? onSwipeReply;

  @override
  Widget build(BuildContext context) {
    final m = message;
    final mine = m.mine;
    final bg = mine ? AppColors.primary : Colors.white;
    final fg = mine ? Colors.white : const Color(0xFF17221A);
    final sub = mine ? Colors.white70 : const Color(0xFF687469);

    final bubble = GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(18),
            topEnd: const Radius.circular(18),
            bottomStart: Radius.circular(mine ? 18 : 4),
            bottomEnd: Radius.circular(mine ? 4 : 18),
          ),
          border: mine ? null : Border.all(color: const Color(0xFFE2E9E1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!mine)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('خدمة العملاء',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            if (m.replyPreview != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: mine ? Colors.white24 : const Color(0xFFEAF5EA),
                  borderRadius: BorderRadius.circular(8),
                  border: BorderDirectional(
                      start: BorderSide(
                          color: mine ? Colors.white : AppColors.primary,
                          width: 3)),
                ),
                child: Text(m.replyPreview!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: sub)),
              ),
            if (m.deleted)
              Text('رسالة محذوفة',
                  style: TextStyle(
                      color: sub, fontStyle: FontStyle.italic, fontSize: 14))
            else ...[
              if (m.imageUrl != null)
                Padding(
                  padding: EdgeInsets.only(bottom: m.body != null ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => _ImageViewer(
                            url: m.imageUrl!, cacheKey: 'support-${m.id}'))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: m.imageUrl!,
                        // The signed link changes on every load; the
                        // message id does not.
                        cacheKey: 'support-${m.id}',
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            width: 220,
                            height: 220,
                            color: Colors.black12,
                            child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))),
                        errorWidget: (_, __, ___) => Container(
                            width: 220,
                            height: 120,
                            color: Colors.black12,
                            child: const Icon(Icons.broken_image_outlined)),
                      ),
                    ),
                  ),
                ),
              if (m.body != null)
                // Plain text: a long press opens the actions (copy is there).
                Text(m.body!,
                    style: TextStyle(color: fg, fontSize: 15, height: 1.4)),
            ],
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_time(m.createdAt),
                    style: TextStyle(fontSize: 11, color: sub)),
                if (mine && !m.deleted) ...[
                  const SizedBox(width: 4),
                  Icon(m.read ? Icons.done_all_rounded : Icons.done_rounded,
                      size: 15,
                      color: m.read ? const Color(0xFFB7F0BC) : Colors.white70),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    final aligned = Align(
      alignment:
          mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: bubble,
    );
    if (onSwipeReply == null) return aligned;
    return Dismissible(
      key: ValueKey('swipe${m.id}'),
      direction: mine ? DismissDirection.endToStart : DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        HapticFeedback.selectionClick();
        onSwipeReply!();
        return false;
      },
      background: Align(
        alignment: mine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.reply_rounded, color: AppColors.primary),
        ),
      ),
      child: aligned,
    );
  }
}

class _PendingBubble extends StatelessWidget {
  const _PendingBubble({required this.pending, required this.onRetry});
  final _Pending pending;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final p = pending;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GestureDetector(
        onTap: p.failed ? onRetry : null,
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (p.image != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(p.image!,
                        width: 220, height: 220, fit: BoxFit.cover),
                  ),
                ),
              if (p.body != null)
                Text(p.body!,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      p.failed
                          ? Icons.error_outline_rounded
                          : Icons.schedule_rounded,
                      size: 14,
                      color: Colors.white),
                  const SizedBox(width: 4),
                  Text(p.failed ? 'لم تُرسل — اضغط لإعادة المحاولة' : 'جارٍ الإرسال…',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemNote extends StatelessWidget {
  const _SystemNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF8A5A12))),
      ),
    );
  }
}

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E9E1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4F5B51))),
      ),
    );
  }
}

class _ComposerBanner extends StatelessWidget {
  const _ComposerBanner(
      {required this.icon, required this.text, required this.onClose});
  final IconData icon;
  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsetsDirectional.only(start: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EA),
        borderRadius: BorderRadius.circular(10),
        border: BorderDirectional(
            start: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
          ),
          IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 18)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.support_agent_rounded,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text('كيف نقدر نساعدك؟',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'اكتب سؤالك أو مشكلتك، ويمكنك إرفاق صورة. فريق خدمة عملاء Goal Master سيرد عليك هنا وستصلك رسالة إشعار.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF687469), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.url, required this.cacheKey});
  final String url;
  final String cacheKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: CachedNetworkImage(
              imageUrl: url, cacheKey: cacheKey, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

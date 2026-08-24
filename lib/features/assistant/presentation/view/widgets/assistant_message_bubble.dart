import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    super.key,
    required this.message,
    required this.onQuickReply,
    required this.isLatest,
    this.avatarUrl,
  });

  final AssistantMessage message;
  final void Function(QuickReply) onQuickReply;
  final bool isLatest;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final isCaptain = message.isCaptain;

    return Column(
      crossAxisAlignment:
          isCaptain ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment:
              isCaptain ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isCaptain) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF418946),
                // Not `backgroundImage:` — CircleAvatar always centers that,
                // and the uploaded artwork is a tall character illustration
                // where a centered crop cuts off the face. ClipOval + a
                // top-aligned Image keeps the face in frame instead.
                child: avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.support_agent,
                              color: Colors.white,
                              size: 16),
                        ),
                      )
                    : const Icon(Icons.support_agent,
                        color: Colors.white, size: 16),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isCaptain ? Colors.grey.shade200 : AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.body,
                  style: TextStyle(
                    color: isCaptain ? Colors.black87 : Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
        if (message.voiceUrl != null)
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              bottom: 2,
              right: isCaptain ? 38 : 0,
            ),
            child: _VoiceNoteButton(url: message.voiceUrl!),
          ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 6,
            right: isCaptain ? 38 : 0,
          ),
          child: Text(
            _formatTime(message.createdAt),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
        ),
        if (isLatest && (message.quickReplies?.isNotEmpty ?? false))
          _hasImages(message.quickReplies!)
              ? _QuickReplyCardScroller(
                  replies: message.quickReplies!,
                  onTap: onQuickReply,
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: message.quickReplies!
                        .map((reply) => ActionChip(
                              label: Text(reply.label),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppColors.primary),
                              labelStyle: TextStyle(color: AppColors.primary),
                              onPressed: () => onQuickReply(reply),
                            ))
                        .toList(),
                  ),
                ),
      ],
    );
  }

  bool _hasImages(List<QuickReply> replies) =>
      replies.any((r) => r.imageUrl != null);

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    final local = dt.toLocal();
    final hour24 = local.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'م' : 'ص';
    return '$hour12:$minute $period';
  }
}

/// Play/pause button for an admin-recorded voice reply — just plays back a
/// stored file, no text-to-speech involved.
class _VoiceNoteButton extends StatefulWidget {
  const _VoiceNoteButton({required this.url});

  final String url;

  @override
  State<_VoiceNoteButton> createState() => _VoiceNoteButtonState();
}

class _VoiceNoteButtonState extends State<_VoiceNoteButton> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Fixed pseudo-waveform bar heights — a real amplitude analysis would need
  // decoding the whole file client-side just for cosmetics, not worth it.
  static const _barHeights = [
    6.0, 12.0, 8.0, 16.0, 10.0, 18.0, 9.0, 14.0, 7.0, 16.0,
    11.0, 6.0, 13.0, 9.0, 15.0, 8.0, 12.0, 7.0, 10.0, 6.0, //
  ];

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted)
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(UrlSource(widget.url));
      setState(() => _isPlaying = true);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final shownDuration = _duration > Duration.zero ? _duration : _position;
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final activeBars = (progress * _barHeights.length).round();

    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        constraints: const BoxConstraints(minWidth: 170),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: AppColors.primary,
              size: 26,
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_barHeights.length, (i) {
                final played = i < activeBars;
                return Container(
                  width: 2.5,
                  height: _barHeights[i],
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: played
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(shownDuration),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrollable image cards — used for branch/field selection so
/// the customer can see a photo and service type, not just a text label.
class _QuickReplyCardScroller extends StatelessWidget {
  const _QuickReplyCardScroller({required this.replies, required this.onTap});

  final List<QuickReply> replies;
  final void Function(QuickReply) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          reverse: true, // RTL: first card starts from the right
          itemCount: replies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final reply = replies[index];
            return GestureDetector(
              onTap: () => onTap(reply),
              child: Container(
                width: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: reply.imageUrl != null
                          ? Image.network(
                              reply.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.sports_soccer,
                                    color: Colors.grey, size: 32),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.sports_soccer,
                                  color: Colors.grey, size: 32),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            reply.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          if (reply.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              reply.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

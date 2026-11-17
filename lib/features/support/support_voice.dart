import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// A finished recording the person chose to send.
class VoiceRecording {
  VoiceRecording(this.file, this.durationMs);
  final File file;
  final int durationMs;
}

/// Records a voice message in a bottom sheet: the clock while recording
/// (stops by itself at [maxSeconds]), cancel, stop, then listen before
/// sending or delete. AAC (.m4a), mono, small. Returns the recording, or null.
class VoiceRecorderSheet extends StatefulWidget {
  const VoiceRecorderSheet({super.key, this.maxSeconds = 120});

  final int maxSeconds;

  static Future<VoiceRecording?> show(BuildContext context,
      {int maxSeconds = 120}) async {
    // The recorder asks for the microphone itself the first time.
    final probe = AudioRecorder();
    final allowed = await probe.hasPermission();
    await probe.dispose();
    if (!allowed) {
      showCustomFailureToast(
          'اسمح للتطبيق باستخدام الميكروفون من إعدادات الهاتف لإرسال رسالة صوتية.');
      return null;
    }
    if (!context.mounted) return null;
    return showModalBottomSheet<VoiceRecording>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceRecorderSheet(maxSeconds: maxSeconds),
    );
  }

  @override
  State<VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<VoiceRecorderSheet> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _clock;
  DateTime? _started;
  Duration _elapsed = Duration.zero;
  String? _path;
  bool _recording = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 32000,
            sampleRate: 22050,
            numChannels: 1),
        path: path,
      );
      _started = DateTime.now();
      if (!mounted) return;
      setState(() => _recording = true);
      _clock = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!mounted || _started == null) return;
        setState(() => _elapsed = DateTime.now().difference(_started!));
        if (_elapsed.inSeconds >= widget.maxSeconds) _stop();
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر تشغيل الميكروفون.');
    }
  }

  Future<void> _stop() async {
    _clock?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    if (_elapsed.inMilliseconds < 700 || path == null) {
      setState(() {
        _recording = false;
        _error = 'التسجيل قصير جدًا. تحدّث لثانية على الأقل.';
      });
      return;
    }
    setState(() {
      _recording = false;
      _path = path;
    });
  }

  Future<void> _discard() async {
    _clock?.cancel();
    if (_recording) await _recorder.cancel();
    if (_path != null) {
      try {
        await File(_path!).delete();
      } catch (_) {}
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _clock?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  String _fmt(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _round(IconData icon, String label, Color bg, Color fg,
      VoidCallback onTap) {
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: fg, size: 26),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = AppColors.primary;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, 18 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_path == null ? 'رسالة صوتية' : 'استمع قبل الإرسال',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17221A))),
        const SizedBox(height: 18),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.errorRed)),
          )
        else if (_path == null)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _RecDot(active: _recording),
            const SizedBox(width: 10),
            Text(_fmt(_elapsed),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: Color(0xFF17221A))),
          ])
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                color: green, borderRadius: BorderRadius.circular(18)),
            child: VoiceBubble(
                filePath: _path,
                durationMs: _elapsed.inMilliseconds,
                onDark: true),
          ),
        const SizedBox(height: 8),
        Text(
            _path == null
                ? 'الحد الأقصى ${widget.maxSeconds} ثانية'
                : 'المدة ${_fmt(_elapsed)}',
            style: const TextStyle(color: Color(0xFF687469), fontSize: 12.5)),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _round(
              Icons.delete_outline,
              _path == null ? 'إلغاء التسجيل' : 'حذف التسجيل',
              const Color(0xFFFDECEC),
              AppColors.errorRed,
              _discard),
          if (_path == null && _error == null)
            _round(Icons.stop_rounded, 'إنهاء التسجيل', green, Colors.white,
                _stop)
          else if (_path != null)
            _round(
                Icons.send_rounded,
                'إرسال الرسالة الصوتية',
                green,
                Colors.white,
                () => Navigator.of(context).pop(
                    VoiceRecording(File(_path!), _elapsed.inMilliseconds))),
        ]),
      ]),
    );
  }
}

class _RecDot extends StatefulWidget {
  const _RecDot({required this.active});
  final bool active;

  @override
  State<_RecDot> createState() => _RecDotState();
}

class _RecDotState extends State<_RecDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations || !widget.active;
    return FadeTransition(
      opacity: still
          ? const AlwaysStoppedAnimation(1)
          : Tween(begin: 0.3, end: 1.0).animate(_c),
      child: Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
              color: Color(0xFFE11D48), shape: BoxShape.circle)),
    );
  }
}

/// A voice message in a chat bubble: play / pause, seek, time, speed
/// 1x / 1.5x / 2x. [url] is the signed link from the server ([filePath] for a
/// recording not sent yet). One voice message plays at a time.
class VoiceBubble extends StatefulWidget {
  const VoiceBubble({
    super.key,
    this.url,
    this.filePath,
    required this.durationMs,
    this.onDark = false,
    this.expired = false,
  });

  final String? url;
  final String? filePath;
  final int durationMs;

  /// Drawn on the green bubble (the person's own message).
  final bool onDark;
  final bool expired;

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  static _VoiceBubbleState? _playing;

  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription> _subs = [];
  Duration _position = Duration.zero;
  Duration? _duration;
  PlayerState _state = PlayerState.stopped;
  double _rate = 1;
  bool _failed = false;

  /// The source is loaded once and kept (ReleaseMode.stop), and a tap while
  /// the player is still working is ignored: loading the source twice at
  /// the same time crashed the native player on a quick double tap.
  bool _loaded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.stop);
    _subs.add(_player.onPositionChanged
        .listen((p) => mounted ? setState(() => _position = p) : null));
    _subs.add(_player.onDurationChanged
        .listen((d) => mounted ? setState(() => _duration = d) : null));
    _subs.add(_player.onPlayerStateChanged
        .listen((s) => mounted ? setState(() => _state = s) : null));
    _subs.add(_player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _position = Duration.zero);
    }));
  }

  @override
  void dispose() {
    if (_playing == this) _playing = null;
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_busy) return;
    _busy = true;
    try {
      if (_state == PlayerState.playing) {
        await _player.pause();
        return;
      }
      if (_playing != null && _playing != this) {
        await _playing!._player.pause();
      }
      _playing = this;
      if (mounted) setState(() => _failed = false);
      if (!_loaded) {
        await _player.setSource(widget.filePath != null
            ? DeviceFileSource(widget.filePath!)
            : UrlSource(widget.url!));
        _loaded = true;
      } else if (_state == PlayerState.completed ||
          _state == PlayerState.stopped) {
        await _player.seek(Duration.zero);
      }
      await _player.setPlaybackRate(_rate);
      await _player.resume();
    } catch (_) {
      _loaded = false;
      if (mounted) setState(() => _failed = true);
    } finally {
      _busy = false;
    }
  }

  Future<void> _speed() async {
    final next = _rate == 1 ? 1.5 : (_rate == 1.5 ? 2.0 : 1.0);
    setState(() => _rate = next);
    try {
      await _player.setPlaybackRate(next);
    } catch (_) {}
  }

  String _fmt(Duration d) {
    final s = d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final green = AppColors.primary;
    final fg = widget.onDark ? Colors.white : const Color(0xFF17221A);
    if (widget.expired || (widget.url == null && widget.filePath == null)) {
      return Text('انتهت مدة الاحتفاظ بهذه الرسالة الصوتية',
          style: TextStyle(color: fg.withValues(alpha: 0.8), fontSize: 13));
    }
    final total = _duration ?? Duration(milliseconds: widget.durationMs);
    final max =
        total.inMilliseconds <= 0 ? 1.0 : total.inMilliseconds.toDouble();
    final value = _position.inMilliseconds.clamp(0, max.toInt()).toDouble();
    final playing = _state == PlayerState.playing;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Semantics(
          button: true,
          label: playing ? 'إيقاف مؤقت' : 'تشغيل الرسالة الصوتية',
          child: InkResponse(
            onTap: _toggle,
            radius: 24,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.onDark ? Colors.white : green),
              child: Icon(playing ? Icons.pause : Icons.play_arrow,
                  color: widget.onDark ? green : Colors.white, size: 24),
            ),
          ),
        ),
        SizedBox(
          width: 110,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: fg,
              inactiveTrackColor: fg.withValues(alpha: 0.3),
              thumbColor: fg,
            ),
            child: Slider(
              value: value,
              max: max,
              onChanged: (v) =>
                  _player.seek(Duration(milliseconds: v.toInt())),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
            _failed
                ? 'تعذّر'
                : _fmt(playing || _position > Duration.zero
                    ? _position
                    : total),
            style: TextStyle(
                color: fg,
                fontSize: 12,
                fontFeatures: const [FontFeature.tabularFigures()])),
        const SizedBox(width: 6),
        Semantics(
          button: true,
          label: 'سرعة التشغيل',
          child: InkWell(
            onTap: _speed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  border: Border.all(color: fg.withValues(alpha: 0.8)),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                  '${_rate == 1 ? '1' : (_rate == 2 ? '2' : '1.5')}x',
                  style: TextStyle(
                      color: fg, fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ]),
    );
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

enum PenaltySfx { whistle, kick, whoosh, glove, net, post, cheer, groan }

/// Stadium audio shared by the games. Every call swallows platform errors:
/// sound is a garnish and must never be the reason a kick fails.
///
/// Lifetime rules (the crowd loop used to outlive its page):
/// - players get unique ids — a fixed id let a new page's player replace an
///   old one natively, orphaning a looping crowd nobody could stop;
/// - [dispose] stops everything and wins over an [init] still in flight;
/// - every live instance is tracked so [stopAll] can silence them all;
/// - the crowd pauses while the app is in the background.
class PenaltySounds {
  PenaltySounds({this.enabled = true});

  final bool enabled;
  static bool muted = false;

  static final _live = <PenaltySounds>{};

  /// Silences every game sound currently alive (used on mute and on exit).
  static Future<void> stopAll() async {
    for (final s in _live.toList()) {
      await s._silence();
    }
  }

  final _players = <PenaltySfx, AudioPlayer>{};
  AudioPlayer? _crowd;
  double _crowdVolume = 0.32;
  bool _disposed = false;
  AppLifecycleListener? _lifecycle;
  bool _background = false;

  static const _volumes = {
    PenaltySfx.whistle: 0.7,
    PenaltySfx.kick: 1.0,
    PenaltySfx.whoosh: 0.75,
    PenaltySfx.glove: 0.9,
    PenaltySfx.net: 0.85,
    PenaltySfx.post: 0.8,
    PenaltySfx.cheer: 0.9,
    PenaltySfx.groan: 0.7,
  };

  static bool _contextSet = false;

  /// Game sounds mix with whatever the player is listening to instead of
  /// stopping it.
  static Future<void> _ensureContext() async {
    if (_contextSet) return;
    _contextSet = true;
    try {
      await AudioPlayer.global.setAudioContext(
          AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build());
    } catch (_) {}
  }

  Future<void> init() async {
    if (!enabled || _disposed) return;
    _live.add(this);
    _lifecycle = AppLifecycleListener(
      onHide: () {
        _background = true;
        _silence();
      },
      onShow: () {
        _background = false;
        _resumeCrowd();
      },
    );
    final created = <AudioPlayer>[];
    await _ensureContext();
    try {
      for (final sfx in PenaltySfx.values) {
        final player = AudioPlayer();
        created.add(player);
        try {
          await player.setPlayerMode(PlayerMode.lowLatency);
        } catch (_) {}
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource('audio/penalty/${sfx.name}.wav'));
        if (_disposed) break;
        _players[sfx] = player;
      }
      if (!_disposed) {
        final crowd = AudioPlayer();
        created.add(crowd);
        await crowd.setReleaseMode(ReleaseMode.loop);
        await crowd.setSource(AssetSource('audio/penalty/crowd_loop.wav'));
        if (!_disposed) {
          _crowd = crowd;
          await _resumeCrowd();
        }
      }
    } catch (e) {
      debugPrint('penalty audio unavailable: $e');
    }
    // The page went away while we were loading: release what we made.
    if (_disposed) {
      for (final p in created) {
        await _release(p);
      }
    }
  }

  Future<void> _resumeCrowd() async {
    final crowd = _crowd;
    if (crowd == null || muted || _disposed || _background) return;
    try {
      await crowd.setVolume(_crowdVolume);
      await crowd.resume();
    } catch (_) {}
  }

  Future<void> play(PenaltySfx sfx, {double? volume}) async {
    if (!enabled || muted || _disposed || _background) return;
    final player = _players[sfx];
    if (player == null) return;
    try {
      await player.stop();
      await player.setVolume(volume ?? _volumes[sfx]!);
      await player.resume();
    } catch (_) {}
  }

  Future<void> setMuted(bool value) async {
    muted = value;
    if (value) {
      await stopAll();
    } else {
      for (final s in _live.toList()) {
        await s._resumeCrowd();
      }
    }
  }

  /// Crowd swells with the moment, e.g. while the ball is in the air.
  Future<void> crowdLevel(double volume) async {
    _crowdVolume = volume;
    if (!enabled || muted || _disposed || _background) return;
    try {
      await _crowd?.setVolume(volume);
    } catch (_) {}
  }

  Future<void> _silence() async {
    for (final p in [if (_crowd != null) _crowd!, ..._players.values]) {
      try {
        await p.pause();
      } catch (_) {}
    }
  }

  static Future<void> _release(AudioPlayer p) async {
    try {
      await p.stop();
    } catch (_) {}
    try {
      await p.dispose();
    } catch (_) {}
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _live.remove(this);
    _lifecycle?.dispose();
    _lifecycle = null;
    final all = [if (_crowd != null) _crowd!, ..._players.values];
    _crowd = null;
    _players.clear();
    for (final p in all) {
      await _release(p);
    }
  }
}

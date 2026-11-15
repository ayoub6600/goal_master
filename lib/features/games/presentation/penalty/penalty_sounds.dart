import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum PenaltySfx { whistle, kick, glove, net, post, cheer, groan }

/// Stadium audio. Every call swallows platform errors: sound is a garnish
/// and must never be the reason a kick fails.
class PenaltySounds {
  PenaltySounds({this.enabled = true});

  final bool enabled;
  static bool muted = false;

  final _players = <PenaltySfx, AudioPlayer>{};
  AudioPlayer? _crowd;

  static const _volumes = {
    PenaltySfx.whistle: 0.7,
    PenaltySfx.kick: 1.0,
    PenaltySfx.glove: 0.9,
    PenaltySfx.net: 0.8,
    PenaltySfx.post: 0.75,
    PenaltySfx.cheer: 0.9,
    PenaltySfx.groan: 0.7,
  };

  Future<void> init() async {
    if (!enabled) return;
    try {
      for (final sfx in PenaltySfx.values) {
        final player = AudioPlayer(playerId: 'penalty_${sfx.name}');
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource('audio/penalty/${sfx.name}.wav'));
        _players[sfx] = player;
      }
      final crowd = AudioPlayer(playerId: 'penalty_crowd');
      await crowd.setReleaseMode(ReleaseMode.loop);
      await crowd.setSource(AssetSource('audio/penalty/crowd_loop.wav'));
      _crowd = crowd;
      if (!muted) await crowd.setVolume(0.32).then((_) => crowd.resume());
    } catch (e) {
      debugPrint('penalty audio unavailable: $e');
    }
  }

  Future<void> play(PenaltySfx sfx) async {
    if (!enabled || muted) return;
    final player = _players[sfx];
    if (player == null) return;
    try {
      await player.stop();
      await player.setVolume(_volumes[sfx]!);
      await player.resume();
    } catch (_) {}
  }

  Future<void> setMuted(bool value) async {
    muted = value;
    try {
      if (value) {
        await _crowd?.pause();
        for (final p in _players.values) {
          await p.stop();
        }
      } else {
        await _crowd?.setVolume(0.32);
        await _crowd?.resume();
      }
    } catch (_) {}
  }

  /// Crowd swells with the moment, e.g. while the ball is in the air.
  Future<void> crowdLevel(double volume) async {
    if (!enabled || muted) return;
    try {
      await _crowd?.setVolume(volume);
    } catch (_) {}
  }

  Future<void> dispose() async {
    for (final p in [..._players.values, if (_crowd != null) _crowd!]) {
      try {
        await p.dispose();
      } catch (_) {}
    }
    _players.clear();
  }
}

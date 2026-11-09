import 'dart:async';
import 'dart:convert';
import 'package:alarm/alarm.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:noor/core/services/app_prefs.dart';
import 'package:quran/quran.dart' as quran;

class QuranReciter {
  final String folder;
  final int qdcId;
  final String fullSurahServerBase;
  final String nameAr;
  final String nameEn;
  final String nameFr;

  const QuranReciter({
    required this.folder,
    required this.qdcId,
    required this.fullSurahServerBase,
    required this.nameAr,
    required this.nameEn,
    required this.nameFr,
  });

  String label(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return nameAr;
    if (code == 'fr') return nameFr;
    return nameEn;
  }

  /// Fallback direct full-surah MP3 URL (`001.mp3` .. `114.mp3`).
  String fallbackSurahUrl(int surah) {
    final s = surah.toString().padLeft(3, '0');
    return '$fullSurahServerBase/$s.mp3';
  }
}

const List<QuranReciter> kQuranReciters = [
  QuranReciter(
    folder: 'Alafasy_128kbps',
    qdcId: 7,
    fullSurahServerBase: 'https://server8.mp3quran.net/afs',
    nameAr: 'مشاري راشد العفاسي',
    nameEn: 'Mishary Rashid Alafasy',
    nameFr: 'Mishary Rashid Alafasy',
  ),
  QuranReciter(
    folder: 'Ghamadi_40kbps',
    qdcId: 4,
    fullSurahServerBase: 'https://server7.mp3quran.net/s_gmd',
    nameAr: 'سعد الغامدي',
    nameEn: 'Saad Al-Ghamdi',
    nameFr: 'Saad Al-Ghamdi',
  ),
  QuranReciter(
    folder: 'Husary_128kbps',
    qdcId: 6,
    fullSurahServerBase: 'https://server13.mp3quran.net/husr',
    nameAr: 'محمود خليل الحصري',
    nameEn: 'Mahmoud Khalil Al-Husary',
    nameFr: 'Mahmoud Khalil Al-Husary',
  ),
  QuranReciter(
    folder: 'Abdurrahmaan_As-Sudais_192kbps',
    qdcId: 3,
    fullSurahServerBase: 'https://server11.mp3quran.net/sds',
    nameAr: 'عبد الرحمن السديس',
    nameEn: 'Abdurrahman As-Sudais',
    nameFr: 'Abdurrahman As-Sudais',
  ),
  QuranReciter(
    folder: 'MaherAlMuaiqly128kbps',
    qdcId: 9,
    fullSurahServerBase: 'https://server12.mp3quran.net/maher',
    nameAr: 'ماهر المعيقلي',
    nameEn: 'Maher Al-Muaiqly',
    nameFr: 'Maher Al-Muaiqly',
  ),
  QuranReciter(
    folder: 'Minshawy_Murattal_128kbps',
    qdcId: 8,
    fullSurahServerBase: 'https://server10.mp3quran.net/minsh',
    nameAr: 'محمد صديق المنشاوي',
    nameEn: 'Mohamed Siddiq Al-Minshawi',
    nameFr: 'Mohamed Siddiq Al-Minshawi',
  ),
];

QuranReciter reciterByFolder(String folder) {
  for (final r in kQuranReciters) {
    if (r.folder == folder) return r;
  }
  return kQuranReciters.first;
}

/// Builds the EveryAyah single-verse audio URL (`SSSAAA.mp3`).
String everyAyahUrl(String folder, int surah, int ayah) {
  final s = surah.toString().padLeft(3, '0');
  final a = ayah.toString().padLeft(3, '0');
  return 'https://everyayah.com/data/$folder/$s$a.mp3';
}

class _VerseTimestamp {
  final int ayah;
  final int fromMs;
  final int toMs;

  const _VerseTimestamp({
    required this.ayah,
    required this.fromMs,
    required this.toMs,
  });
}

class _SurahAudioData {
  final String audioUrl;
  final List<_VerseTimestamp> timestamps;

  const _SurahAudioData({
    required this.audioUrl,
    required this.timestamps,
  });
}

final AudioContext _kBackgroundAudioContext = AudioContext(
  iOS: AudioContextIOS(
    category: AVAudioSessionCategory.playback,
    options: const {AVAudioSessionOptions.mixWithOthers},
  ),
  android: const AudioContextAndroid(
    isSpeakerphoneOn: false,
    stayAwake: true,
    contentType: AndroidContentType.music,
    usageType: AndroidUsageType.media,
    // AndroidAudioFocus.none prevents audioplayers_android's FocusManager from
    // registering an OnAudioFocusChangeListener that auto-invokes MediaPlayer.start()
    // when an Adhan alarm finishes and abandons its transient audio focus.
    audioFocus: AndroidAudioFocus.none,
  ),
);

/// Playback behavior when a surah finishes playing.
enum QuranPlayMode {
  /// Automatically continues to the next surah.
  continuous('continuous'),

  /// Loops the current surah from the beginning.
  loop('loop'),

  /// Stops when the current surah finishes.
  stopAtEnd('stopAtEnd');

  final String key;
  const QuranPlayMode(this.key);

  static QuranPlayMode fromKey(String raw) {
    for (final m in QuranPlayMode.values) {
      if (m.key == raw) return m;
    }
    return QuranPlayMode.continuous;
  }

  QuranPlayMode get next {
    switch (this) {
      case QuranPlayMode.continuous:
        return QuranPlayMode.loop;
      case QuranPlayMode.loop:
        return QuranPlayMode.stopAtEnd;
      case QuranPlayMode.stopAtEnd:
        return QuranPlayMode.continuous;
    }
  }

  String label(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    switch (this) {
      case QuranPlayMode.continuous:
        if (code == 'ar') return 'تشغيل متواصل';
        if (code == 'fr') return 'Lecture continue';
        return 'Continuous';
      case QuranPlayMode.loop:
        if (code == 'ar') return 'تكرار السورة';
        if (code == 'fr') return 'Répéter la sourate';
        return 'Loop Surah';
      case QuranPlayMode.stopAtEnd:
        if (code == 'ar') return 'يتوقف عند النهاية';
        if (code == 'fr') return 'Arrêter à la fin';
        return 'Stop at end';
    }
  }
}

/// Manages full-surah continuous Quran audio playback (with real-time verse
/// timestamp syncing) as well as single-verse preview from the Mushaf reader,
/// plus Android background notification controls.
class QuranAudioController extends GetxController {
  static const MethodChannel _appChannel = MethodChannel('noor/app');

  static QuranAudioController get instance =>
      Get.isRegistered<QuranAudioController>()
          ? Get.find<QuranAudioController>()
          : Get.put(QuranAudioController(), permanent: true);

  AudioPlayer? _player;
  StreamSubscription<void>? _completeSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<dynamic>? _alarmRingingSub;

  final Rxn<({int surah, int ayah})> playingAyah =
      Rxn<({int surah, int ayah})>();
  final Rxn<({int surah, int ayah})> lastListened =
      Rxn<({int surah, int ayah})>();
  final RxBool isPlaying = false.obs;
  final RxBool isFullSurahMode = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxString reciterFolder = AppPrefs.defaultQuranReciter.obs;
  final Rx<QuranPlayMode> playMode = QuranPlayMode.continuous.obs;

  /// Optional callback invoked when playback advances to an ayah on a different page.
  void Function(int pageNumber)? onPageTurnRequested;

  bool _continuous = true;
  bool _hasLoadedSource = false;
  int _playRequestId = 0;

  final Map<String, _SurahAudioData> _surahCache = {};
  List<_VerseTimestamp> _activeTimestamps = const [];
  List<double> _cumulativeWeights = const [];

  @override
  void onInit() {
    super.onInit();
    reciterFolder.value = AppPrefs.quranReciter;
    playMode.value = QuranPlayMode.fromKey(AppPrefs.quranPlayMode);
    lastListened.value = AppPrefs.lastListenedQuran;
    _setupMediaActionReceiver();
    _setupAlarmRingingGuard();
  }

  void _saveLastListened(int surah, int ayah) {
    lastListened.value = (surah: surah, ayah: ayah);
    try {
      AppPrefs.setLastListenedQuran(surah, ayah);
    } catch (_) {}
  }

  void _setupAlarmRingingGuard() {
    try {
      _alarmRingingSub = Alarm.ringing.listen((ringing) {
        if (ringing.alarms.isNotEmpty) {
          if (isPlaying.value) {
            pause();
          } else if (_player != null) {
            _player?.pause();
          }
        }
      });
    } catch (_) {}
  }

  Future<void> setPlayMode(QuranPlayMode mode) async {
    playMode.value = mode;
    try {
      await AppPrefs.setQuranPlayMode(mode.key);
    } catch (_) {}
    _pushMediaNotification();
  }

  Future<void> cyclePlayMode() => setPlayMode(playMode.value.next);

  void _setupMediaActionReceiver() {
    try {
      _appChannel.setMethodCallHandler((call) async {
        if (call.method == 'mediaAction') {
          final action = call.arguments as String?;
          switch (action) {
            case 'toggle':
              await togglePlayPause();
              break;
            case 'play':
              if (!isPlaying.value) await resume();
              break;
            case 'pause':
              if (isPlaying.value) {
                await pause();
              } else {
                try {
                  await _player?.pause();
                } catch (_) {}
              }
              break;
            case 'rewind':
              await seekBy(const Duration(seconds: -5));
              break;
            case 'fast_forward':
              await seekBy(const Duration(seconds: 5));
              break;
            case 'prev':
              await previousVerse();
              break;
            case 'next':
              await nextVerse();
              break;
            case 'mode':
              await cyclePlayMode();
              break;
            case 'stop':
              await stop();
              break;
          }
        } else if (call.method == 'mediaSeekTo') {
          final posMs = (call.arguments as num?)?.toInt();
          if (posMs != null && posMs >= 0) {
            await seekTo(Duration(milliseconds: posMs));
          }
        }
      });
    } catch (_) {}
  }

  AudioPlayer _ensurePlayer() {
    if (_player != null) return _player!;
    final p = AudioPlayer();
    try {
      p.setAudioContext(_kBackgroundAudioContext);
      p.setReleaseMode(ReleaseMode.release);
    } catch (_) {}
    _completeSub = p.onPlayerComplete.listen((_) {
      _onPlaybackComplete();
    });
    _posSub = p.onPositionChanged.listen((pos) {
      if (!isPlaying.value) {
        try {
          if (playingAyah.value == null) {
            p.stop();
          } else {
            p.pause();
          }
        } catch (_) {}
        return;
      }
      position.value = pos;
      if (isFullSurahMode.value) {
        _syncVerseFromPosition(pos);
      }
    });
    _durSub = p.onDurationChanged.listen((dur) {
      duration.value = dur;
      _pushMediaNotification();
    });
    _player = p;
    return p;
  }

  Future<_SurahAudioData> _resolveSurahAudio(
      QuranReciter reciter, int surah) async {
    final key = '${reciter.folder}:$surah';
    final cached = _surahCache[key];
    if (cached != null) return cached;

    try {
      final uri = Uri.parse(
        'https://api.quran.com/api/v4/chapter_recitations/${reciter.qdcId}/$surah?segments=true',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final audioFile = decoded['audio_file'] as Map<String, dynamic>?;
        if (audioFile != null) {
          final audioUrl = (audioFile['audio_url'] as String?) ??
              reciter.fallbackSurahUrl(surah);
          final rawTimestamps = audioFile['timestamps'] as List<dynamic>? ?? [];
          final timestamps = <_VerseTimestamp>[];
          for (final item in rawTimestamps) {
            if (item is Map<String, dynamic>) {
              final vk = item['verse_key'] as String? ?? '';
              final parts = vk.split(':');
              final ayahNum =
                  parts.length == 2 ? (int.tryParse(parts[1]) ?? 0) : 0;
              final fromMs = (item['timestamp_from'] as num?)?.toInt() ?? 0;
              final toMs = (item['timestamp_to'] as num?)?.toInt() ?? 0;
              if (ayahNum >= 1 && toMs >= fromMs) {
                timestamps.add(_VerseTimestamp(
                  ayah: ayahNum,
                  fromMs: fromMs,
                  toMs: toMs,
                ));
              }
            }
          }
          final data = _SurahAudioData(
            audioUrl: audioUrl,
            timestamps: timestamps,
          );
          _surahCache[key] = data;
          return data;
        }
      }
    } catch (_) {}

    return _SurahAudioData(
      audioUrl: reciter.fallbackSurahUrl(surah),
      timestamps: const [],
    );
  }

  void _buildCumulativeWeights(int surah) {
    final count = quran.getVerseCount(surah);
    final weights = <double>[];
    var total = 0.0;
    for (var a = 1; a <= count; a++) {
      final len = quran.getVerse(surah, a).length.toDouble();
      total += len > 0 ? len : 1.0;
      weights.add(total);
    }
    if (total > 0) {
      _cumulativeWeights = [for (final w in weights) w / total];
    } else {
      _cumulativeWeights = const [];
    }
  }

  void _syncVerseFromPosition(Duration pos) {
    final current = playingAyah.value;
    if (current == null) return;
    final posMs = pos.inMilliseconds;
    int? resolvedAyah;

    if (_activeTimestamps.isNotEmpty) {
      for (final ts in _activeTimestamps) {
        if (posMs >= ts.fromMs && posMs <= ts.toMs) {
          resolvedAyah = ts.ayah;
          break;
        }
      }
      if (resolvedAyah == null && posMs > _activeTimestamps.last.toMs) {
        resolvedAyah = _activeTimestamps.last.ayah;
      }
    } else if (duration.value.inMilliseconds > 0 &&
        _cumulativeWeights.isNotEmpty) {
      final frac = (posMs / duration.value.inMilliseconds).clamp(0.0, 1.0);
      for (var i = 0; i < _cumulativeWeights.length; i++) {
        if (frac <= _cumulativeWeights[i]) {
          resolvedAyah = i + 1;
          break;
        }
      }
    }

    if (resolvedAyah != null && resolvedAyah != current.ayah) {
      final oldAyah = current.ayah;
      playingAyah.value = (surah: current.surah, ayah: resolvedAyah);
      _saveLastListened(current.surah, resolvedAyah);
      _notifyPageTurnIfNeeded(
        current.surah,
        oldAyah,
        current.surah,
        resolvedAyah,
      );
      _pushMediaNotification();
    }
  }

  Future<void> setReciter(String folder) async {
    reciterFolder.value = folder;
    try {
      await AppPrefs.setQuranReciter(folder);
    } catch (_) {}
    final current = playingAyah.value;
    if (current != null && isPlaying.value) {
      if (isFullSurahMode.value) {
        await playSurah(current.surah, startAyah: current.ayah);
      } else {
        await playVerse(current.surah, current.ayah, continuous: _continuous);
      }
    } else if (current != null && isFullSurahMode.value) {
      _pushMediaNotification();
    }
  }

  /// Plays the entire [surah] as one continuous audio stream, syncing the
  /// displayed verse as playback progresses.
  Future<void> playSurah(int surah, {int startAyah = 1}) async {
    final reqId = ++_playRequestId;
    isFullSurahMode.value = true;
    _continuous = true;
    _activeTimestamps = const [];
    _buildCumulativeWeights(surah);
    playingAyah.value = (surah: surah, ayah: startAyah);
    _saveLastListened(surah, startAyah);
    isPlaying.value = true;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    _pushMediaNotification();

    final reciter = reciterByFolder(reciterFolder.value);
    try {
      final player = _ensurePlayer();
      await player.stop();
      final data = await _resolveSurahAudio(reciter, surah);
      if (reqId != _playRequestId) return;
      _activeTimestamps = data.timestamps;
      _hasLoadedSource = true;
      await player.play(UrlSource(data.audioUrl));

      if (startAyah > 1 && _activeTimestamps.isNotEmpty) {
        for (final ts in _activeTimestamps) {
          if (ts.ayah == startAyah) {
            await seekTo(Duration(milliseconds: ts.fromMs));
            break;
          }
        }
      }
    } catch (_) {
      // Keep playingAyah so the player UI remains inspectable offline / in tests.
      isPlaying.value = false;
      _pushMediaNotification();
    }
  }

  /// Plays an individual verse (`SSSAAA.mp3`), used by the Mushaf reader's
  /// Ayah Action Sheet. Defaults to [continuous] = `false` so playback stops
  /// as soon as this single verse finishes.
  Future<void> playVerse(
    int surah,
    int ayah, {
    bool continuous = false,
  }) async {
    ++_playRequestId;
    isFullSurahMode.value = false;
    _continuous = continuous;
    playingAyah.value = (surah: surah, ayah: ayah);
    isPlaying.value = true;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    if (continuous) {
      _pushMediaNotification();
    } else {
      _cancelMediaNotification();
    }

    final url = everyAyahUrl(reciterFolder.value, surah, ayah);
    try {
      final player = _ensurePlayer();
      await player.stop();
      _hasLoadedSource = true;
      await player.play(UrlSource(url));
    } catch (_) {
      isPlaying.value = false;
      if (continuous) {
        _pushMediaNotification();
      }
    }
  }

  Future<void> toggleVerse(
    int surah,
    int ayah, {
    bool continuous = false,
  }) async {
    final current = playingAyah.value;
    if (current != null &&
        current.surah == surah &&
        current.ayah == ayah &&
        isPlaying.value) {
      if (isFullSurahMode.value || _continuous != continuous) {
        await stop();
      } else {
        await pause();
      }
      return;
    }
    if (current != null &&
        current.surah == surah &&
        current.ayah == ayah &&
        !isPlaying.value &&
        !isFullSurahMode.value &&
        _continuous == continuous &&
        _hasLoadedSource) {
      await resume();
      return;
    }
    await playVerse(surah, ayah, continuous: continuous);
  }

  Future<void> togglePlayPause() async {
    final current = playingAyah.value;
    if (current == null) return;
    if (isPlaying.value) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> resume() async {
    final current = playingAyah.value;
    if (current == null) return;
    if (!_hasLoadedSource) {
      if (isFullSurahMode.value) {
        await playSurah(current.surah, startAyah: current.ayah);
      } else {
        await playVerse(current.surah, current.ayah, continuous: _continuous);
      }
      return;
    }
    isPlaying.value = true;
    if (isFullSurahMode.value || _continuous) {
      _pushMediaNotification();
    }
    try {
      await _player?.resume();
    } catch (_) {
      if (isFullSurahMode.value) {
        await playSurah(current.surah, startAyah: current.ayah);
      } else {
        await playVerse(current.surah, current.ayah, continuous: _continuous);
      }
    }
  }

  Future<void> pause() async {
    isPlaying.value = false;
    if (isFullSurahMode.value || _continuous) {
      _pushMediaNotification();
    }
    try {
      await _player?.pause();
    } catch (_) {}
  }

  Future<void> stop() async {
    ++_playRequestId;
    isPlaying.value = false;
    isFullSurahMode.value = false;
    playingAyah.value = null;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    _activeTimestamps = const [];
    _hasLoadedSource = false;
    _cancelMediaNotification();
    try {
      await _player?.stop();
    } catch (_) {}
  }

  /// Moves playback position by [delta] (e.g. +5s or -5s) within the stream.
  Future<void> seekBy(Duration delta) async {
    if (playingAyah.value == null) return;
    final dur = duration.value;
    var target = position.value + delta;
    if (target < Duration.zero) {
      target = Duration.zero;
    } else if (dur > Duration.zero && target > dur) {
      target = dur;
    }
    await seekTo(target);
  }

  Future<void> seekTo(Duration target) async {
    position.value = target;
    if (isFullSurahMode.value) {
      _syncVerseFromPosition(target);
    }
    if (isFullSurahMode.value || _continuous) {
      _pushMediaNotification();
    }
    try {
      await _player?.seek(target);
    } catch (_) {}
  }

  Future<void> nextVerse() async {
    final current = playingAyah.value;
    if (current == null) return;
    final maxAyah = quran.getVerseCount(current.surah);

    if (isFullSurahMode.value) {
      if (current.ayah < maxAyah) {
        final nextAyah = current.ayah + 1;
        playingAyah.value = (surah: current.surah, ayah: nextAyah);
        _saveLastListened(current.surah, nextAyah);
        _notifyPageTurnIfNeeded(
            current.surah, current.ayah, current.surah, nextAyah);
        _pushMediaNotification();
        if (_activeTimestamps.isNotEmpty) {
          for (final ts in _activeTimestamps) {
            if (ts.ayah == nextAyah) {
              await seekTo(Duration(milliseconds: ts.fromMs));
              break;
            }
          }
        }
        return;
      } else {
        final nextSurah = current.surah < 114 ? current.surah + 1 : 1;
        _notifyPageTurnIfNeeded(current.surah, current.ayah, nextSurah, 1);
        await playSurah(nextSurah, startAyah: 1);
        return;
      }
    }

    int nextSurah = current.surah;
    int nextAyah = current.ayah + 1;
    if (nextAyah > maxAyah) {
      if (current.surah < 114) {
        nextSurah = current.surah + 1;
        nextAyah = 1;
      } else {
        nextAyah = 1;
      }
    }
    _notifyPageTurnIfNeeded(current.surah, current.ayah, nextSurah, nextAyah);
    await playVerse(nextSurah, nextAyah, continuous: _continuous);
  }

  Future<void> previousVerse() async {
    final current = playingAyah.value;
    if (current == null) return;

    if (isFullSurahMode.value) {
      if (current.ayah > 1) {
        final prevAyah = current.ayah - 1;
        playingAyah.value = (surah: current.surah, ayah: prevAyah);
        _saveLastListened(current.surah, prevAyah);
        _notifyPageTurnIfNeeded(
            current.surah, current.ayah, current.surah, prevAyah);
        _pushMediaNotification();
        if (_activeTimestamps.isNotEmpty) {
          for (final ts in _activeTimestamps) {
            if (ts.ayah == prevAyah) {
              await seekTo(Duration(milliseconds: ts.fromMs));
              break;
            }
          }
        }
        return;
      } else {
        final prevSurah = current.surah > 1 ? current.surah - 1 : 114;
        _notifyPageTurnIfNeeded(current.surah, current.ayah, prevSurah, 1);
        await playSurah(prevSurah, startAyah: 1);
        return;
      }
    }

    if (position.value > const Duration(seconds: 3)) {
      await seekTo(Duration.zero);
      return;
    }
    int prevSurah = current.surah;
    int prevAyah = current.ayah - 1;
    if (prevAyah < 1) {
      if (current.surah > 1) {
        prevSurah = current.surah - 1;
        prevAyah = quran.getVerseCount(prevSurah);
      } else {
        prevAyah = 1;
      }
    }
    _notifyPageTurnIfNeeded(current.surah, current.ayah, prevSurah, prevAyah);
    await playVerse(prevSurah, prevAyah, continuous: _continuous);
  }

  void _notifyPageTurnIfNeeded(
      int oldSurah, int oldAyah, int newSurah, int newAyah) {
    final currentPage = quran.getPageNumber(oldSurah, oldAyah);
    final nextPage = quran.getPageNumber(newSurah, newAyah);
    if (nextPage != currentPage) {
      onPageTurnRequested?.call(nextPage);
    }
  }

  void _onPlaybackComplete() {
    if (!isPlaying.value || !_continuous) {
      stop();
      return;
    }
    final current = playingAyah.value;
    if (current == null) return;

    if (isFullSurahMode.value) {
      switch (playMode.value) {
        case QuranPlayMode.loop:
          playSurah(current.surah, startAyah: 1);
          return;
        case QuranPlayMode.stopAtEnd:
          isPlaying.value = false;
          _hasLoadedSource = false;
          playingAyah.value = (surah: current.surah, ayah: 1);
          position.value = Duration.zero;
          _pushMediaNotification();
          return;
        case QuranPlayMode.continuous:
          if (current.surah < 114) {
            final nextSurah = current.surah + 1;
            _notifyPageTurnIfNeeded(current.surah, current.ayah, nextSurah, 1);
            playSurah(nextSurah, startAyah: 1);
          } else {
            stop();
          }
          return;
      }
    }

    final maxAyah = quran.getVerseCount(current.surah);
    int nextSurah = current.surah;
    int nextAyah = current.ayah + 1;

    if (nextAyah > maxAyah) {
      if (current.surah < 114) {
        nextSurah = current.surah + 1;
        nextAyah = 1;
      } else {
        stop();
        return;
      }
    }

    _notifyPageTurnIfNeeded(current.surah, current.ayah, nextSurah, nextAyah);
    playVerse(nextSurah, nextAyah, continuous: true);
  }

  void _pushMediaNotification() {
    final current = playingAyah.value;
    if (current == null) {
      _cancelMediaNotification();
      return;
    }
    final reciter = reciterByFolder(reciterFolder.value);
    final surahArName = quran.getSurahNameArabic(current.surah);
    final surahEnName = quran.getSurahName(current.surah);
    final surahAr = 'سورة $surahArName';
    try {
      _appChannel.invokeMethod('updateMediaNotification', {
        'surahNumber': current.surah,
        'surahAr': surahArName,
        'surahEn': surahEnName,
        'title': surahAr,
        'subtitle': reciter.nameAr,
        'isPlaying': isPlaying.value,
        'positionMs': position.value.inMilliseconds,
        'durationMs': duration.value.inMilliseconds,
        'playMode': playMode.value.key,
      });
    } catch (_) {}
  }

  void _cancelMediaNotification() {
    try {
      _appChannel.invokeMethod('cancelMediaNotification');
    } catch (_) {}
  }

  @override
  void onClose() {
    _alarmRingingSub?.cancel();
    _completeSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _cancelMediaNotification();
    _player?.dispose();
    super.onClose();
  }
}

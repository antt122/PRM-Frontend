import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/podcast.dart';
import 'audio_cache_manager.dart';

/// Global audio player service with background support and persistent caching
/// Singleton pattern - one instance for entire app
class AudioPlayerService extends ChangeNotifier {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  AudioPlayerService._internal() {
    _init();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  Podcast? _currentPodcast;
  bool _isInitialized = false;
  bool _isLoadingNewPodcast = false; // ✅ Track when downloading new podcast

  // ✅ Use persistent cache manager instead of in-memory map
  final CacheManager _cacheManager = AudioCacheManager.instance;

  // Getters
  AudioPlayer get player => _audioPlayer;
  Podcast? get currentPodcast => _currentPodcast;
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;

  // ✅ Return Duration.zero while loading new podcast to prevent showing old duration
  Duration get duration {
    if (_isLoadingNewPodcast) {
      return Duration.zero; // Show 0:00 while downloading
    }
    return _audioPlayer.duration ?? Duration.zero;
  }

  Duration get bufferedPosition => _audioPlayer.bufferedPosition;
  bool get hasAudio => _currentPodcast != null;
  bool get isLoadingNewPodcast => _isLoadingNewPodcast;

  // Streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  void _init() {
    if (_isInitialized) return;

    // Listen to player completion
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Reset position when completed
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
      notifyListeners();
    });

    _isInitialized = true;
  }

  /// Play or switch to a new podcast
  Future<void> playPodcast(Podcast podcast) async {
    try {
      // If same podcast, just toggle play/pause
      if (_currentPodcast?.id == podcast.id) {
        if (_audioPlayer.playing) {
          await pause();
        } else {
          await resume();
        }
        return;
      }

      // New podcast - load and play
      _currentPodcast = podcast;

      // ✅ IMPORTANT: Reset player state BEFORE loading new audio
      // This prevents showing old podcast's progress while downloading new one
      await _audioPlayer.stop();
      await _audioPlayer.seek(Duration.zero);

      // ✅ Set loading flag to show duration = 0:00 while downloading
      _isLoadingNewPodcast = true;

      notifyListeners(); // Update UI immediately with reset state (0:00 / 0:00)

      if (podcast.audioFileUrl == null) {
        throw Exception('Audio URL is null');
      }

      final audioUrl = podcast.audioFileUrl!;

      print('🎵 Loading audio from: $audioUrl');

      // ✅ On Web: Direct URL playback (browser handles caching)
      // ✅ On Mobile/Desktop: Use file cache for offline support
      if (kIsWeb) {
        // WEB: Load directly from URL (browser cache handles it)
        print('🌐 Web platform: Loading audio directly from URL');

        final audioSource = AudioSource.uri(Uri.parse(audioUrl));

        await _audioPlayer.setAudioSource(audioSource);

        // ✅ Clear loading flag
        _isLoadingNewPodcast = false;

        await _audioPlayer.play();
        print('✅ Audio playing from URL: ${podcast.title}');
      } else {
        // MOBILE/DESKTOP: Try direct URL first, then fallback to cache
        print('📱 Mobile/Desktop platform: Trying direct URL first');

        try {
          // Try direct URL playback first (simpler approach)
          print('🎵 Attempting direct URL playback: $audioUrl');
          final audioSource = AudioSource.uri(Uri.parse(audioUrl));

          await _audioPlayer.setAudioSource(audioSource);

          // ✅ Clear loading flag
          _isLoadingNewPodcast = false;

          await _audioPlayer.play();
          print('✅ Audio playing directly from URL: ${podcast.title}');
        } catch (e) {
          print('❌ Direct URL failed: $e');
          print('📱 Falling back to file cache...');

          // Fallback to file cache
          final fileInfo = await _cacheManager.getFileFromCache(audioUrl);

          if (fileInfo != null && fileInfo.file.existsSync()) {
            // ✅ CACHE HIT - Load from disk instantly
            print('✅ Cache HIT! Loading from: ${fileInfo.file.path}');
            print('✅ File size: ${fileInfo.file.lengthSync()} bytes');

            final audioSource = AudioSource.file(fileInfo.file.path);

            await _audioPlayer.setAudioSource(audioSource);

            // ✅ Clear loading flag
            _isLoadingNewPodcast = false;

            await _audioPlayer.play();
            print('✅ Audio playing from cache: ${podcast.title}');
          } else {
            // ✅ CACHE MISS - Download and cache
            print('📥 Cache MISS. Downloading...');

            final file = await _cacheManager.downloadFile(
              audioUrl,
              authHeaders: {
                'ngrok-skip-browser-warning': 'true',
                'User-Agent': 'Flutter-Client',
              },
            );

            print('✅ Downloaded and cached: ${file.file.path}');
            print('✅ File size: ${file.file.lengthSync()} bytes');

            final audioSource = AudioSource.file(file.file.path);

            await _audioPlayer.setAudioSource(audioSource);

            // ✅ Clear loading flag
            _isLoadingNewPodcast = false;

            await _audioPlayer.play();
            print('✅ Audio playing: ${podcast.title}');
          }
        }
      }
    } catch (e, stackTrace) {
      // ✅ Reset loading flag on error
      _isLoadingNewPodcast = false;
      notifyListeners();

      print('❌ Error playing podcast: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Resume playback
  Future<void> resume() async {
    await _audioPlayer.play();
    notifyListeners();
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  /// Skip forward 10 seconds
  Future<void> skipForward() async {
    final newPosition = _audioPlayer.position + const Duration(seconds: 10);
    await seek(newPosition);
  }

  /// Skip backward 10 seconds
  Future<void> skipBackward() async {
    final newPosition = _audioPlayer.position - const Duration(seconds: 10);
    await seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  /// Stop and clear current podcast
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentPodcast = null;
    notifyListeners();
  }

  /// Clear audio cache (persistent disk cache)
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    print('✅ Audio cache cleared from disk');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

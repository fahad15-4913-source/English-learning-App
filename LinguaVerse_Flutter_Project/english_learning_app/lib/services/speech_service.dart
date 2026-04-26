import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';

class SpeechService {
  static final FlutterTts _tts = FlutterTts();
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _isInitialized = true;
  }

  // ── Text-to-Speech ──
  static Future<void> speak(String text, {double rate = 0.45}) async {
    await initialize();
    await _tts.setSpeechRate(rate);
    await _tts.speak(text);
  }

  static Future<void> speakSlow(String text) async {
    await speak(text, rate: 0.3);
  }

  static Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // ── Speech-to-Text ──
  static Future<bool> initSpeechRecognition() async {
    return await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
  }

  static Future<void> startListening({
    required Function(String) onResult,
    required Function() onDone,
  }) async {
    final available = await _speech.initialize();
    if (!available) return;

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          onDone();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }

  static bool get isListening => _speech.isListening;

  // ── Sound Effects ──
  static Future<void> playCorrectSound() async {
    await _audioPlayer.play(AssetSource('audio/correct.mp3'));
  }

  static Future<void> playWrongSound() async {
    await _audioPlayer.play(AssetSource('audio/wrong.mp3'));
  }

  static Future<void> playLevelUpSound() async {
    await _audioPlayer.play(AssetSource('audio/levelup.mp3'));
  }

  static Future<void> playAchievementSound() async {
    await _audioPlayer.play(AssetSource('audio/achievement.mp3'));
  }

  static void dispose() {
    _tts.stop();
    _speech.stop();
    _audioPlayer.dispose();
  }
}

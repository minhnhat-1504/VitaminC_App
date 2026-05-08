import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

// ─── MODEL: Kết quả chấm điểm phát âm ───
class PronunciationResult {
  final String referenceText;
  final String recognizedText;
  final double accuracyScore;
  final List<WordResult> wordResults;

  PronunciationResult({
    required this.referenceText,
    required this.recognizedText,
    required this.accuracyScore,
    required this.wordResults,
  });
}

class WordResult {
  final String word;
  final bool isCorrect;

  WordResult({required this.word, required this.isCorrect});
}

// ─── SERVICE: Xử lý giọng nói & chấm điểm phát âm ───
class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedText = '';

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastRecognizedText => _lastRecognizedText;

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    if (result.isGranted) return true;

    if (result.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) return false;

    try {
      _isInitialized = await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
        debugLogging: kDebugMode,
      );
    } catch (e) {
      debugPrint('>>> SPEECH ENGINE INIT ERROR: $e');
      _isInitialized = false;
    }

    debugPrint('>>> SPEECH ENGINE READY: $_isInitialized');
    return _isInitialized;
  }

  void _onSpeechError(SpeechRecognitionError error) {
    debugPrint('>>> SPEECH ERROR: ${error.errorMsg} (${error.permanent})');
    _isListening = false;
  }

  void _onSpeechStatus(String status) {
    debugPrint('>>> SPEECH STATUS: $status');
    if (status == 'notListening' || status == 'done') {
      _isListening = false;
    }
  }

  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_isInitialized) {
      final ready = await initialize();
      if (!ready) return;
    }

    _lastRecognizedText = '';
    _isListening = true;

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastRecognizedText = result.recognizedWords;
          onResult(result.recognizedWords, result.finalResult);
        },
        localeId: localeId,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      );
    } catch (e) {
      debugPrint('>>> SPEECH LISTEN ERROR: $e');
      _isListening = false;
    }
  }

  Future<String> stopListening() async {
    await _speech.stop();
    _isListening = false;
    return _lastRecognizedText;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _isListening = false;
    _lastRecognizedText = '';
  }

  static int levenshteinDistance(String a, String b) {
    final int m = a.length;
    final int n = b.length;
    final List<List<int>> dp = List.generate(
      m + 1,
      (_) => List.filled(n + 1, 0),
    );

    for (int i = 0; i <= m; i++) dp[i][0] = i;
    for (int j = 0; j <= n; j++) dp[0][j] = j;

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final int cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce(min);
      }
    }
    return dp[m][n];
  }

  PronunciationResult assessPronunciation({
    required String referenceText,
    required String recognizedText,
  }) {
    final refWords = _normalizeAndSplit(referenceText);
    final recWords = _normalizeAndSplit(recognizedText);

    if (refWords.isEmpty) {
      return PronunciationResult(
        referenceText: referenceText,
        recognizedText: recognizedText,
        accuracyScore: 0,
        wordResults: [],
      );
    }

    int correctCount = 0;
    final List<WordResult> wordResults = [];

    for (int i = 0; i < refWords.length; i++) {
      final refWord = refWords[i];
      bool matched = false;

      for (final recWord in recWords) {
        final distance = levenshteinDistance(refWord, recWord);
        final maxLen = max(refWord.length, recWord.length);
        final threshold = (maxLen * 0.3).ceil();

        if (distance <= threshold) {
          matched = true;
          break;
        }
      }

      if (matched) correctCount++;
      wordResults.add(WordResult(word: refWord, isCorrect: matched));
    }

    final double score = (correctCount / refWords.length) * 100;

    return PronunciationResult(
      referenceText: referenceText,
      recognizedText: recognizedText,
      accuracyScore: double.parse(score.toStringAsFixed(1)),
      wordResults: wordResults,
    );
  }

  List<String> _normalizeAndSplit(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  void dispose() {
    _speech.stop();
    _speech.cancel();
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService();
  ref.onDispose(() => service.dispose());
  return service;
});

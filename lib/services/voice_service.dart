import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../core/utils/logger.dart';

enum VoiceState { idle, listening, speaking, processing }

class VoiceService {
  final _speech = stt.SpeechToText();
  final _tts = FlutterTts();

  bool _speechInitialized = false;
  final _transcriptController = StreamController<String>.broadcast();
  final _stateController = StreamController<VoiceState>.broadcast();

  Stream<String> get transcriptStream => _transcriptController.stream;
  Stream<VoiceState> get stateStream => _stateController.stream;

  Future<void> initialize() async {
    _speechInitialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _stateController.add(VoiceState.idle);
        }
      },
      onError: (error) {
        AppLogger.e('VoiceService', 'STT error: ${error.errorMsg}');
        _stateController.add(VoiceState.idle);
      },
    );

    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _stateController.add(VoiceState.speaking));
    _tts.setCompletionHandler(() => _stateController.add(VoiceState.idle));
  }

  Future<void> startListening({required Function(String) onResult}) async {
    if (!_speechInitialized) await initialize();
    if (!_speechInitialized) return;

    _stateController.add(VoiceState.listening);

    await _speech.listen(
      onResult: (result) {
        _transcriptController.add(result.recognizedWords);
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      localeId: 'en_US',
      listenMode: stt.ListenMode.confirmation,
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 60),
      cancelOnError: false,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _stateController.add(VoiceState.processing);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    final cleanText = _stripMarkdown(text);
    await _tts.speak(cleanText);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _stateController.add(VoiceState.idle);
  }

  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*{1,2}(.*?)\*{1,2}'), r'$1')
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'`{1,3}(.*?)`{1,3}'), r'$1')
        .trim();
  }

  Future<bool> get isAvailable async {
    if (!_speechInitialized) {
      _speechInitialized = await _speech.initialize();
    }
    return _speechInitialized;
  }

  void dispose() {
    _transcriptController.close();
    _stateController.close();
    _speech.stop();
    _tts.stop();
  }
}

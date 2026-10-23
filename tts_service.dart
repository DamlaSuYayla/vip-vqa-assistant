import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dio/dio.dart';

import '../constants.dart';

class TtsService {
  AppLanguage _language = AppLanguage.en;
  final Dio _dio = Dio();

  Future<void> init() async {
    await setLanguage(_language);
  }

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
  }

  Future<void> speak(String text, {AppLanguage? language}) async {
    if (text.trim().isEmpty) {
      return;
    }
    try {
      final AppLanguage effectiveLanguage = language ?? _language;
      _language = effectiveLanguage;
      await _speakElevenLabs(text, _ttsLanguageCode(effectiveLanguage));
    } catch (_) {
      // Spoken feedback is best-effort; visible text remains on screen.
    }
  }

  Future<void> speakAndWait(String text, {AppLanguage? language}) async {
    if (text.trim().isEmpty) {
      return;
    }
    try {
      final AppLanguage effectiveLanguage = language ?? _language;
      _language = effectiveLanguage;
      await _speakElevenLabs(text, _ttsLanguageCode(effectiveLanguage));
      await Future<void>.delayed(_fallbackDuration(text));
    } catch (_) {
      // Auto-navigation should not stall if the browser refuses speech.
    }
  }

  Future<void> stop() async {
    try {
      globalContext.callMethodVarArgs('stopSpeaking'.toJS, []);
    } catch (_) {
      // No recovery needed.
    }
  }

  
  void unlockAudio() {
    try {
      globalContext.callMethodVarArgs('unlockAudio'.toJS, []);
    } catch (_) {
      // No recovery needed.
    }
  }

  Future<void> _speakElevenLabs(String text, String lang) async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.post<Map<String, dynamic>>(
        '/.netlify/functions/tts',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'text': text,
          'lang': lang,
        },
      );

      final String? base64Audio = response.data?['audio'] as String?;
      if (response.statusCode == 200 && base64Audio != null) {
        globalContext.callMethodVarArgs(
          'playAudioFromBase64'.toJS,
          [base64Audio.toJS],
        );
        return;
      }
      _speakJs(text, lang);
    } catch (_) {
      // Fallback to Web Speech if the TTS function fails.
      _speakJs(text, lang);
    }
  }

  void _speakJs(String text, String lang) {
    globalContext.callMethodVarArgs('speakText'.toJS, [
      text.toJS,
      lang.toJS,
      AppTtsConstants.speechRate.toJS,
      AppTtsConstants.pitch.toJS,
    ]);
  }

  String _ttsLanguageCode(AppLanguage language) {
    final String languageCodeValue = languageCode(language);
    return languageCodeValue == 'es'
        ? 'es-ES'
        : languageCodeValue == 'fr'
            ? 'fr-FR'
            : 'en-US';
  }

  Duration _fallbackDuration(String text) {
    final int wordCount =
        text.trim().split(RegExp(AppTtsConstants.whitespacePattern)).length;
    final Duration estimate = AppDurations.ttsFallbackBase +
        (AppDurations.ttsFallbackPerWord * wordCount);
    if (estimate > AppDurations.ttsFallbackMax) {
      return AppDurations.ttsFallbackMax;
    }
    return estimate;
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../app/routes.dart';
import '../constants.dart';
import '../models/vqa_answer.dart';
import '../services/translation_service.dart';
import '../services/tts_service.dart';
import '../services/vqa_api_service.dart';
import 'capture_controller.dart';
import 'gate_controller.dart';
import 'language_controller.dart';
import 'question_controller.dart';

class VqaController extends GetxController {
  VqaController(
    this._captureController,
    this._questionController,
    this._languageController,
    this._translationService,
    this._vqaApiService,
    this._ttsService,
  );

  final CaptureController _captureController;
  final QuestionController _questionController;
  final LanguageController _languageController;
  final TranslationService _translationService;
  final VqaApiService _vqaApiService;
  final TtsService _ttsService;

  final RxBool isLoading = false.obs;
  final Rxn<VqaAnswer> answer = Rxn<VqaAnswer>();
  final RxString localizedAnswer = kEmptyString.obs;
  final RxString errorMessage = kEmptyString.obs;

  Timer? _warmupTimer;

  Future<void> askCurrentQuestion() async {
    final AppLanguage language = _languageController.currentLanguage.value;
    final String currentLanguageCode = languageCode(language);
    final Uint8List? photoBytes = _captureController.imageBytes.value;
    final String question = _questionController.trimmedQuestion;

    if (photoBytes == null) {
      await _showLocalError(language, AppTextKey.noPhotoError);
      return;
    }
    if (question.isEmpty) {
      await _showLocalError(language, AppTextKey.emptyQuestionError);
      return;
    }

    isLoading.value = true;
    answer.value = null;
    localizedAnswer.value = kEmptyString;
    errorMessage.value = kEmptyString;
    Get.toNamed(AppRoutes.processing);

    try {
      final String originalQuestion = question;

      String translatedQuestion = originalQuestion;
      if (currentLanguageCode != 'en') {
        translatedQuestion = await _translationService.translate(
          originalQuestion,
          from: currentLanguageCode,
          to: 'en',
        );
      }

      _startWarmupAnnouncement(language);

      final Stopwatch apiStopwatch = Stopwatch()..start();
      final VqaAnswer englishAnswer = await _vqaApiService.ask(
        base64Image: base64Encode(photoBytes),
        englishQuestion: translatedQuestion,
      );
      apiStopwatch.stop();
      final int apiLatencyMs = apiStopwatch.elapsedMilliseconds;
      final int gateLatencyMs = Get.find<GateController>().gateLatencyMs;
      final int totalLatencyMs = gateLatencyMs + apiLatencyMs;

      debugPrint("=== LATENCY ===");
      debugPrint("Gate: ${gateLatencyMs}ms");
      debugPrint("API: ${apiLatencyMs}ms");
      debugPrint("Total: ${totalLatencyMs}ms");

      _warmupTimer?.cancel();

      final String englishAnswerText = englishAnswer.answer;

      String finalAnswer = englishAnswerText;
      if (currentLanguageCode != 'en') {
        finalAnswer = await _translationService.translate(
          englishAnswerText,
          from: 'en',
          to: currentLanguageCode,
        );
      }

      answer.value = englishAnswer.copyWith(
        answer: finalAnswer,
        gateLatencyMs: gateLatencyMs,
        apiLatencyMs: apiLatencyMs,
        totalLatencyMs: totalLatencyMs,
      );
      localizedAnswer.value = finalAnswer;
      Get.offNamed(AppRoutes.answer);
    } catch (error) {
      _warmupTimer?.cancel();
      final String message = _messageForError(language, error);
      errorMessage.value = message;
      Get.offNamed(AppRoutes.home);
      Get.snackbar(
        localized(language, AppTextKey.snackbarTitle),
        message,
        duration: AppDurations.snackbar,
      );
      await _ttsService.speak(message, language: language);
    } finally {
      _warmupTimer?.cancel();
      isLoading.value = false;
    }
  }

  void clearAnswer() {
    answer.value = null;
    localizedAnswer.value = kEmptyString;
    errorMessage.value = kEmptyString;
  }

  void _startWarmupAnnouncement(AppLanguage language) {
    _warmupTimer?.cancel();
    _warmupTimer = Timer(AppDurations.warmupDelay, () {
      if (isLoading.value) {
        _ttsService.speak(
          localized(language, AppTextKey.warmingUp),
          language: language,
        );
      }
    });
  }

  Future<void> _showLocalError(
    AppLanguage language,
    AppTextKey messageKey,
  ) async {
    final String message = localized(language, messageKey);
    Get.snackbar(
      localized(language, AppTextKey.snackbarTitle),
      message,
      duration: AppDurations.snackbar,
    );
    await _ttsService.speak(message, language: language);
  }

  String _messageForError(AppLanguage language, Object error) {
    if (error is VqaApiException) {
      return localized(language, error.messageKey);
    }
    return localized(language, AppTextKey.genericError);
  }

  @override
  void onClose() {
    _warmupTimer?.cancel();
    _translationService.close();
    _vqaApiService.close();
    super.onClose();
  }
}

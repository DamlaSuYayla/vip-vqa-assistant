import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import 'language_controller.dart';

class QuestionController extends GetxController {
  QuestionController(
    this._speechService,
    this._languageController,
    this._ttsService,
  );

  final SpeechService _speechService;
  final LanguageController _languageController;
  final TtsService _ttsService;

  final TextEditingController textController = TextEditingController();
  final RxString question = kEmptyString.obs;
  final RxBool isListening = false.obs;

  String get trimmedQuestion => question.value.trim();

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_syncQuestion);
  }

  Future<void> startListening() async {
    if (!kIsWeb || isListening.value) {
      return;
    }

    final AppLanguage language = _languageController.currentLanguage.value;
    isListening.value = true;
    try {
      final String? result = await _speechService.startListening(
        languageCode(language),
      );
      if (result == null || result.trim().isEmpty) {
        await _showCouldNotHear(language);
        return;
      }
      final String cleanResult = result.trim();
      textController.text = cleanResult;
      textController.selection = TextSelection.collapsed(
        offset: cleanResult.length,
      );
    } catch (_) {
      await _showCouldNotHear(language);
    } finally {
      isListening.value = false;
    }
  }

  void clear() {
    textController.clear();
    question.value = kEmptyString;
  }

  Future<void> _showCouldNotHear(AppLanguage language) async {
    final String message = localized(language, AppTextKey.couldNotHear);
    Get.snackbar(
      localized(language, AppTextKey.snackbarTitle),
      message,
      duration: AppDurations.snackbar,
    );
    await _ttsService.speak(message, language: language);
  }

  void _syncQuestion() {
    question.value = textController.text;
  }

  @override
  void onClose() {
    textController.removeListener(_syncQuestion);
    textController.dispose();
    super.onClose();
  }
}

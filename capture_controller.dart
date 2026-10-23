import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../app/routes.dart';
import '../constants.dart';
import '../models/gate_result.dart';
import '../services/tts_service.dart';
import 'gate_controller.dart';
import 'language_controller.dart';
import 'settings_controller.dart';

class CaptureController extends GetxController {
  CaptureController(
    this._gateController,
    this._settingsController,
    this._languageController,
    this._ttsService,
  );

  final GateController _gateController;
  final SettingsController _settingsController;
  final LanguageController _languageController;
  final TtsService _ttsService;
  final ImagePicker _picker = ImagePicker();

  final Rxn<Uint8List> imageBytes = Rxn<Uint8List>();
  final Rxn<String> imageName = Rxn<String>();
  final RxBool isPicking = false.obs;

  bool get hasPhoto => imageBytes.value != null;

  Future<void> pickPhoto(ImageSource source) async {
    _ttsService.unlockAudio();
    final AppLanguage language = _languageController.currentLanguage.value;
    isPicking.value = true;
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: PickerConstants.maxWidth,
        maxHeight: PickerConstants.maxHeight,
        imageQuality: PickerConstants.imageQuality,
      );

      if (photo == null) {
        await _ttsService.speak(
          localized(language, AppTextKey.captureCancelled),
          language: language,
        );
        return;
      }

      await _captureHaptic();
      final Uint8List bytes = await photo.readAsBytes();

      if (_settingsController.gateDisabled.value) {
        imageBytes.value = bytes;
        imageName.value = photo.name;
        await _gateController.assumePassed();
        await _ttsService.speak(
          localized(language, AppTextKey.photoLooksGoodAskQuestion),
          language: language,
        );
        return;
      }

      final GateResult result = await _gateController.evaluate(bytes);
      if (result.passed) {
        imageBytes.value = bytes;
        imageName.value = photo.name;
        await _ttsService.speak(
          localized(language, AppTextKey.photoLooksGoodAskQuestion),
          language: language,
        );
      } else {
        clearPhoto();
        Get.toNamed(AppRoutes.retake, arguments: result);
      }
    } catch (_) {
      clearPhoto();
      final String message = localized(language, AppTextKey.genericError);
      Get.snackbar(
        localized(language, AppTextKey.snackbarTitle),
        message,
        duration: AppDurations.snackbar,
      );
      await _ttsService.speak(message, language: language);
    } finally {
      isPicking.value = false;
    }
  }

  void clearPhoto() {
    imageBytes.value = null;
    imageName.value = null;
    _gateController.clear();
  }

  void clearAll() {
    clearPhoto();
  }

  Future<void> _captureHaptic() async {
    if (kIsWeb) {
      try {
        await HapticFeedback.selectionClick();
      } catch (_) {
        // Haptics are not supported by every browser.
      }
    }
  }

}

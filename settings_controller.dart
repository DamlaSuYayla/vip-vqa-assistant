import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../services/tts_service.dart';
import 'language_controller.dart';

class SettingsController extends GetxController {
  SettingsController(
    this._prefs,
    this._languageController,
    this._ttsService,
  );

  final SharedPreferences _prefs;
  final LanguageController _languageController;
  final TtsService _ttsService;

  final RxBool gateDisabled = false.obs;

  Future<void> load() async {
    gateDisabled.value = _prefs.getBool(kPrefGateDisabled) ?? false;
  }

  Future<void> setGateDisabled(bool value) async {
    gateDisabled.value = value;
    await _prefs.setBool(kPrefGateDisabled, value);
    if (value) {
      final AppLanguage language = _languageController.currentLanguage.value;
      await _ttsService.speak(
        localized(language, AppTextKey.gateDisabledAnnounce),
        language: language,
      );
    }
  }

  Future<void> setLanguage(AppLanguage language) {
    return _languageController.selectLanguage(language);
  }

}

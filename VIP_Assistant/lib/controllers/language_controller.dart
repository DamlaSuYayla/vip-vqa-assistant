import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../services/tts_service.dart';

class LanguageController extends GetxController {
  LanguageController(this._prefs, this._ttsService);

  final SharedPreferences _prefs;
  final TtsService _ttsService;

  final Rx<AppLanguage> currentLanguage = AppLanguage.en.obs;
  final RxBool hasSelectedLanguage = false.obs;

  Future<void> load() async {
    final String? storedCode = _prefs.getString(kPrefLanguageCode);
    if (storedCode != null) {
      currentLanguage.value = languageFromCode(storedCode);
      hasSelectedLanguage.value = true;
    }
    await _ttsService.setLanguage(currentLanguage.value);
  }

  Future<void> selectLanguage(
    AppLanguage language, {
    bool announce = true,
  }) async {
    currentLanguage.value = language;
    hasSelectedLanguage.value = true;
    await _prefs.setString(kPrefLanguageCode, languageCode(language));
    await _ttsService.setLanguage(language);
    if (announce) {
      await _ttsService.speak(
        localized(language, AppTextKey.languageSaved),
        language: language,
      );
    }
  }

}

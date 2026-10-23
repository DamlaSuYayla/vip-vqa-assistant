import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../controllers/language_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/tts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LanguageController _languageController = Get.find<LanguageController>();
  final SettingsController _settingsController = Get.find<SettingsController>();
  final TtsService _ttsService = Get.find<TtsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AppLanguage language = _languageController.currentLanguage.value;
      _ttsService.speak(
        localized(language, AppTextKey.settingsAnnounce),
        language: language,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AppLanguage language = _languageController.currentLanguage.value;
      return Scaffold(
        appBar: AppBar(
          leading: Semantics(
            label: localized(language, AppTextKey.backButton),
            button: true,
            child: IconButton(
              tooltip: localized(language, AppTextKey.backButton),
              icon: const Icon(Icons.arrow_back),
              onPressed: Get.back,
            ),
          ),
          title: Text(localized(language, AppTextKey.settingsTitle)),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimens.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      localized(language, AppTextKey.languageSettingsLabel),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimens.smallGap),
                    _LanguageButton(
                      currentLanguage: language,
                      value: AppLanguage.en,
                      title: localized(language, AppTextKey.englishButton),
                      onPressed: _settingsController.setLanguage,
                    ),
                    const SizedBox(height: AppDimens.itemGap),
                    _LanguageButton(
                      currentLanguage: language,
                      value: AppLanguage.es,
                      title: localized(language, AppTextKey.spanishButton),
                      onPressed: _settingsController.setLanguage,
                    ),
                    const SizedBox(height: AppDimens.itemGap),
                    _LanguageButton(
                      currentLanguage: language,
                      value: AppLanguage.fr,
                      title: localized(language, AppTextKey.frenchButton),
                      onPressed: _settingsController.setLanguage,
                    ),
                    const SizedBox(height: AppDimens.sectionGap),
                    Semantics(
                      label: localized(language, AppTextKey.gateToggleTitle),
                      toggled: _settingsController.gateDisabled.value,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.accent,
                        title: Text(
                          localized(language, AppTextKey.gateToggleTitle),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          localized(language, AppTextKey.gateToggleSubtitle),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: _settingsController.gateDisabled.value,
                        onChanged: _settingsController.setGateDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.currentLanguage,
    required this.value,
    required this.title,
    required this.onPressed,
  });

  final AppLanguage currentLanguage;
  final AppLanguage value;
  final String title;
  final ValueChanged<AppLanguage> onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentLanguage == value;
    return Semantics(
      label: title,
      button: true,
      selected: isSelected,
      child: SizedBox(
        width: double.infinity,
        child: isSelected
            ? ElevatedButton.icon(
                onPressed: () => onPressed(value),
                icon: const Icon(Icons.check),
                label: Text(title),
              )
            : OutlinedButton.icon(
                onPressed: () => onPressed(value),
                icon: const Icon(Icons.language),
                label: Text(title),
              ),
      ),
    );
  }
}

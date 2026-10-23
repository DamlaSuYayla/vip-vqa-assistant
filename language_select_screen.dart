import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes.dart';
import '../constants.dart';
import '../controllers/language_controller.dart';
import '../services/tts_service.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  final LanguageController _languageController = Get.find<LanguageController>();
  final TtsService _ttsService = Get.find<TtsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ttsService.speak(
        localized(AppLanguage.en, AppTextKey.chooseLanguagePrompt),
        language: AppLanguage.en,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
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
                    localized(AppLanguage.en, AppTextKey.chooseLanguageTitle),
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppDimens.itemGap),
                  Text(
                    localized(AppLanguage.en, AppTextKey.chooseLanguagePrompt),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppDimens.sectionGap),
                  _LanguageButton(
                    label: localized(AppLanguage.en, AppTextKey.englishButton),
                    onPressed: () => _select(AppLanguage.en),
                  ),
                  const SizedBox(height: AppDimens.itemGap),
                  _LanguageButton(
                    label: localized(AppLanguage.es, AppTextKey.spanishButton),
                    onPressed: () => _select(AppLanguage.es),
                  ),
                  const SizedBox(height: AppDimens.itemGap),
                  _LanguageButton(
                    label: localized(AppLanguage.fr, AppTextKey.frenchButton),
                    onPressed: () => _select(AppLanguage.fr),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _select(AppLanguage language) async {
    _ttsService.unlockAudio();
    await _languageController.selectLanguage(language);
    Get.offAllNamed(AppRoutes.home);
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }
}

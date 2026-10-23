import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../controllers/language_controller.dart';
import '../services/tts_service.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final LanguageController _languageController = Get.find<LanguageController>();
  final TtsService _ttsService = Get.find<TtsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AppLanguage language = _languageController.currentLanguage.value;
      _ttsService.speak(localized(language, AppTextKey.thinking),
          language: language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AppLanguage language = _languageController.currentLanguage.value;
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Semantics(
              liveRegion: true,
              label: localized(language, AppTextKey.processingLabel),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    width: AppDimens.progressSize,
                    height: AppDimens.progressSize,
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                  const SizedBox(height: AppDimens.sectionGap),
                  Text(
                    localized(language, AppTextKey.thinking),
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'constants.dart';
import 'controllers/capture_controller.dart';
import 'controllers/gate_controller.dart';
import 'controllers/language_controller.dart';
import 'controllers/question_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/vqa_controller.dart';
import 'services/quality_gate_service.dart';
import 'services/speech_service.dart';
import 'services/translation_service.dart';
import 'services/tts_service.dart';
import 'services/vqa_api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  final TtsService ttsService = Get.put<TtsService>(
    TtsService(),
    permanent: true,
  );
  await ttsService.init();

  final LanguageController languageController = Get.put<LanguageController>(
    LanguageController(prefs, ttsService),
    permanent: true,
  );
  await languageController.load();

  final SettingsController settingsController = Get.put<SettingsController>(
    SettingsController(prefs, languageController, ttsService),
    permanent: true,
  );
  await settingsController.load();

  final QualityGateService qualityGateService = Get.put<QualityGateService>(
    QualityGateService(),
    permanent: true,
  );
  final GateController gateController = Get.put<GateController>(
    GateController(qualityGateService),
    permanent: true,
  );
  final SpeechService speechService = Get.put<SpeechService>(
    SpeechService(),
    permanent: true,
  );
  final TranslationService translationService = Get.put<TranslationService>(
    TranslationService(),
    permanent: true,
  );
  final VqaApiService vqaApiService = Get.put<VqaApiService>(
    VqaApiService(),
    permanent: true,
  );
  final QuestionController questionController = Get.put<QuestionController>(
    QuestionController(speechService, languageController, ttsService),
    permanent: true,
  );
  final CaptureController captureController = Get.put<CaptureController>(
    CaptureController(
      gateController,
      settingsController,
      languageController,
      ttsService,
    ),
    permanent: true,
  );
  Get.put<VqaController>(
    VqaController(
      captureController,
      questionController,
      languageController,
      translationService,
      vqaApiService,
      ttsService,
    ),
    permanent: true,
  );

  runApp(
    VizAssistApp(
      initialRoute: languageController.hasSelectedLanguage.value
          ? AppRoutes.home
          : AppRoutes.language,
    ),
  );
}

class VizAssistApp extends StatelessWidget {
  const VizAssistApp({
    required this.initialRoute,
    super.key,
  });

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: initialRoute,
      getPages: AppRoutes.pages,
    );
  }
}

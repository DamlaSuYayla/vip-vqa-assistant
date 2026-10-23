import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes.dart';
import '../constants.dart';
import '../controllers/capture_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/question_controller.dart';
import '../models/gate_result.dart';
import '../services/tts_service.dart';

class RetakeScreen extends StatefulWidget {
  const RetakeScreen({super.key});

  @override
  State<RetakeScreen> createState() => _RetakeScreenState();
}

class _RetakeScreenState extends State<RetakeScreen> {
  final CaptureController _captureController = Get.find<CaptureController>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final QuestionController _questionController = Get.find<QuestionController>();
  final TtsService _ttsService = Get.find<TtsService>();

  late final GateResult _result;

  @override
  void initState() {
    super.initState();
    final Object? arguments = Get.arguments;
    _result = arguments is GateResult
        ? arguments
        : const GateResult.failed(flaw: GateFlaw.blur);
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceAndReturn());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AppLanguage language = _languageController.currentLanguage.value;
      final GateFlaw flaw = _result.flaw ?? GateFlaw.blur;
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimens.maxContentWidth,
                ),
                child: Semantics(
                  liveRegion: true,
                  label: retakeMessage(language, flaw),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.photo_camera_back,
                        size: AppDimens.progressSize,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: AppDimens.sectionGap),
                      Text(
                        localized(language, AppTextKey.retakeTitle),
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimens.itemGap),
                      Text(
                        retakeMessage(language, flaw),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _announceAndReturn() async {
    final AppLanguage language = _languageController.currentLanguage.value;
    final GateFlaw flaw = _result.flaw ?? GateFlaw.blur;
    await _ttsService.speakAndWait(
      retakeMessage(language, flaw),
      language: language,
    );
    if (!mounted) {
      return;
    }
    _captureController.clearPhoto();
    _questionController.clear();
    Get.offAllNamed(AppRoutes.home);
  }
}

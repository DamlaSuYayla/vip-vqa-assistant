import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes.dart';
import '../constants.dart';
import '../controllers/capture_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/question_controller.dart';
import '../controllers/vqa_controller.dart';
import '../models/vqa_answer.dart';
import '../services/tts_service.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final CaptureController _captureController = Get.find<CaptureController>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final QuestionController _questionController = Get.find<QuestionController>();
  final VqaController _vqaController = Get.find<VqaController>();
  final TtsService _ttsService = Get.find<TtsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceAnswer());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AppLanguage language = _languageController.currentLanguage.value;
      final String answer = _visibleAnswer(language);
      return Scaffold(
        appBar: AppBar(title: Text(localized(language, AppTextKey.answerTitle))),
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
                    Semantics(
                      liveRegion: true,
                      label: answer,
                      child: Text(
                        answer,
                        style: const TextStyle(
                          fontSize: AppDimens.answerText,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.itemGap),
                    Text(
                      _confidenceText(language),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDimens.sectionGap),
                    _ActionButton(
                      label: localized(language, AppTextKey.askAnotherQuestion),
                      icon: Icons.question_answer,
                      onPressed: _askAnotherQuestion,
                    ),
                    const SizedBox(height: AppDimens.itemGap),
                    _SecondaryButton(
                      label: localized(language, AppTextKey.newPhoto),
                      icon: Icons.add_a_photo,
                      onPressed: _newPhoto,
                    ),
                    const SizedBox(height: AppDimens.itemGap),
                    _LatencyText(answer: _vqaController.answer.value),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _announceAnswer() async {
    final AppLanguage language = _languageController.currentLanguage.value;
    await _ttsService.speak(_visibleAnswer(language), language: language);
  }

  String _visibleAnswer(AppLanguage language) {
    final String answer = _vqaController.localizedAnswer.value;
    if (answer.trim().isEmpty) {
      return localized(language, AppTextKey.genericError);
    }
    return answer;
  }

  String _confidenceText(AppLanguage language) {
    final double confidence =
        _vqaController.answer.value?.confidence ?? AppNumberConstants.percentMin;
    final double percent = (confidence * AppNumberConstants.percentMultiplier)
        .clamp(
      AppNumberConstants.percentMin,
      AppNumberConstants.percentMax,
    ).toDouble();
    return localized(language, AppTextKey.answerConfidence) +
        kLabelSeparator +
        percent.toStringAsFixed(AppNumberConstants.percentDigits) +
        AppNumberConstants.percentSymbol;
  }

  void _askAnotherQuestion() {
    _questionController.clear();
    _vqaController.clearAnswer();
    Get.offNamed(AppRoutes.home);
  }

  void _newPhoto() {
    _captureController.clearAll();
    _questionController.clear();
    _vqaController.clearAnswer();
    Get.offNamed(AppRoutes.home);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: AppDimens.iconMedium),
          label: Text(label),
        ),
      ),
    );
  }
}

class _LatencyText extends StatelessWidget {
  const _LatencyText({required this.answer});

  final VqaAnswer? answer;

  @override
  Widget build(BuildContext context) {
    if (answer == null) {
      return const SizedBox.shrink();
    }
    return Text(
      'Gate: ${answer!.gateLatencyMs}ms | '
      'API: ${answer!.apiLatencyMs}ms | '
      'Total: ${answer!.totalLatencyMs}ms',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: AppDimens.iconMedium),
          label: Text(label),
        ),
      ),
    );
  }
}

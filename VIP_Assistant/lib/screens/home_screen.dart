import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../app/routes.dart';
import '../constants.dart';
import '../controllers/capture_controller.dart';
import '../controllers/gate_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/question_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/vqa_controller.dart';
import '../services/tts_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CaptureController _captureController = Get.find<CaptureController>();
  final GateController _gateController = Get.find<GateController>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final QuestionController _questionController = Get.find<QuestionController>();
  final SettingsController _settingsController = Get.find<SettingsController>();
  final VqaController _vqaController = Get.find<VqaController>();
  final TtsService _ttsService = Get.find<TtsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceStep());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final AppLanguage language = _languageController.currentLanguage.value;
      final Uint8List? imageBytes = _captureController.imageBytes.value;
      final bool isBusy =
          _captureController.isPicking.value || _gateController.isEvaluating.value;

      return Scaffold(
        appBar: AppBar(
          title: const SizedBox.shrink(),
          actions: <Widget>[
            Semantics(
              label: localized(language, AppTextKey.openSettings),
              button: true,
              child: SizedBox(
                width: AppDimens.minTouchTarget,
                height: AppDimens.minTouchTarget,
                child: IconButton(
                  tooltip: localized(language, AppTextKey.settingsLabel),
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                  icon: const Icon(Icons.settings),
                ),
              ),
            ),
          ],
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
                    if (_settingsController.gateDisabled.value) ...<Widget>[
                      _EvaluationBanner(language: language),
                      const SizedBox(height: AppDimens.itemGap),
                    ],
                    if (imageBytes == null)
                      _PhotoStep(
                        language: language,
                        isBusy: isBusy,
                        onCamera: () =>
                            _captureController.pickPhoto(ImageSource.camera),
                        onGallery: () =>
                            _captureController.pickPhoto(ImageSource.gallery),
                      )
                    else
                      _QuestionStep(
                        language: language,
                        imageBytes: imageBytes,
                        questionController: _questionController,
                        onAsk: _vqaController.askCurrentQuestion,
                        onRetake: _retakePhoto,
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

  Future<void> _announceStep() async {
    final AppLanguage language = _languageController.currentLanguage.value;
    final AppTextKey key = _captureController.hasPhoto
        ? AppTextKey.photoLooksGoodAskQuestion
        : AppTextKey.takePhotoToGetStarted;
    await _ttsService.speak(localized(language, key), language: language);
  }

  Future<void> _retakePhoto() async {
    _captureController.clearPhoto();
    _questionController.clear();
    final AppLanguage language = _languageController.currentLanguage.value;
    await _ttsService.speak(
      localized(language, AppTextKey.takePhotoToGetStarted),
      language: language,
    );
  }
}

class _EvaluationBanner extends StatelessWidget {
  const _EvaluationBanner({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: localized(language, AppTextKey.evaluationBanner),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.itemGap),
        decoration: BoxDecoration(
          color: AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          border: Border.all(
            color: AppColors.danger,
            width: AppDimens.bannerBorderWidth,
          ),
        ),
        child: Text(
          localized(language, AppTextKey.evaluationBanner),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _PhotoStep extends StatelessWidget {
  const _PhotoStep({
    required this.language,
    required this.isBusy,
    required this.onCamera,
    required this.onGallery,
  });

  final AppLanguage language;
  final bool isBusy;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          localized(language, AppTextKey.takePhotoToGetStarted),
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppDimens.sectionGap),
        if (isBusy)
          _BusyStatus(language: language)
        else ...<Widget>[
          _ActionButton(
            label: localized(language, AppTextKey.cameraButton),
            icon: Icons.camera_alt,
            onPressed: onCamera,
          ),
          const SizedBox(height: AppDimens.itemGap),
          _ActionButton(
            label: localized(language, AppTextKey.galleryButton),
            icon: Icons.photo_library,
            onPressed: onGallery,
          ),
        ],
      ],
    );
  }
}

class _BusyStatus extends StatelessWidget {
  const _BusyStatus({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: localized(language, AppTextKey.checkingPhoto),
      child: Column(
        children: <Widget>[
          const SizedBox(
            width: AppDimens.progressSize,
            height: AppDimens.progressSize,
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          const SizedBox(height: AppDimens.itemGap),
          Text(
            localized(language, AppTextKey.checkingPhoto),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuestionStep extends StatelessWidget {
  const _QuestionStep({
    required this.language,
    required this.imageBytes,
    required this.questionController,
    required this.onAsk,
    required this.onRetake,
  });

  final AppLanguage language;
  final Uint8List imageBytes;
  final QuestionController questionController;
  final VoidCallback onAsk;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          image: true,
          label: localized(language, AppTextKey.selectedPhotoLabel),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.borderRadius),
            child: Container(
              height: AppDimens.imagePreviewHeight,
              color: AppColors.surface,
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.sectionGap),
        Text(
          localized(language, AppTextKey.photoLooksGoodAskQuestion),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppDimens.itemGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Semantics(
                textField: true,
                label: localized(language, AppTextKey.questionFieldLabel),
                child: TextField(
                  controller: questionController.textController,
                  minLines: AppDimens.textFieldMinLines,
                  maxLines: AppDimens.textFieldMaxLines,
                  style: const TextStyle(
                    fontSize: AppDimens.fieldText,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        localized(language, AppTextKey.questionFieldLabel),
                    hintText: localized(language, AppTextKey.questionFieldHint),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.smallGap),
            Obx(() {
              final bool isListening = questionController.isListening.value;
              return Semantics(
                label: isListening
                    ? localized(language, AppTextKey.listeningLabel)
                    : localized(language, AppTextKey.microphoneLabel),
                button: true,
                child: SizedBox(
                  width: AppDimens.micButtonSize,
                  height: AppDimens.micButtonSize,
                  child: IconButton(
                    tooltip: localized(language, AppTextKey.microphoneLabel),
                    onPressed:
                        isListening ? null : questionController.startListening,
                    icon: isListening
                        ? const _PulsingMicIcon()
                        : const Icon(Icons.mic, size: AppDimens.micIconSize),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: AppDimens.sectionGap),
        _ActionButton(
          label: localized(language, AppTextKey.askButton),
          icon: Icons.question_answer,
          onPressed: onAsk,
        ),
        const SizedBox(height: AppDimens.itemGap),
        _SecondaryButton(
          label: localized(language, AppTextKey.retakePhotoButton),
          icon: Icons.refresh,
          onPressed: onRetake,
        ),
      ],
    );
  }
}

class _PulsingMicIcon extends StatefulWidget {
  const _PulsingMicIcon();

  @override
  State<_PulsingMicIcon> createState() => _PulsingMicIconState();
}

class _PulsingMicIconState extends State<_PulsingMicIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.micPulse,
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: AppDimens.micPulseMinScale,
      end: AppDimens.micPulseMaxScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: const Icon(
        Icons.mic,
        color: AppColors.accent,
        size: AppDimens.micIconSize,
      ),
    );
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

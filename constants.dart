import 'package:flutter/material.dart';

const String kAppTitle = 'VQA Assistant';

const String kHfEndpointUrl =
    'https://x0d4be3n61mgq6b3.us-east-1.aws.endpoints.huggingface.cloud';

const String kRouteLanguage = '/language';
const String kRouteHome = '/home';
const String kRouteProcessing = '/processing';
const String kRouteRetake = '/retake';
const String kRouteAnswer = '/answer';
const String kRouteSettings = '/settings';

const String kPrefLanguageCode = 'language_code';
const String kPrefGateDisabled = 'gate_disabled';

const String kJsonInputs = 'inputs';
const String kJsonImage = 'image';
const String kJsonQuestion = 'question';
const String kJsonAnswer = 'answer';
const String kJsonConfidence = 'confidence';

const String kHeaderContentType = 'Content-Type';
const String kHeaderApplicationJson = 'application/json';

const String kSpeechRecognitionFunction = 'startSpeechRecognition';
const String kLabelSeparator = ': ';
const String kEmptyString = '';

class QualityGateConstants {
  static const int resizeLongSide = 640;
  static const double blurThreshold = 100.0;
  static const double darkThreshold = 34.0;
  static const double brightThreshold = 0.2312;
  static const int saturationLevel = 245;
}

class AppDurations {
  static const Duration hfTimeout = Duration(seconds: 90);
  static const Duration warmupDelay = Duration(seconds: 10);
  static const Duration snackbar = Duration(seconds: 5);
  static const Duration shortAnimation = Duration(milliseconds: 250);
  static const Duration micPulse = Duration(milliseconds: 700);
  static const Duration ttsFallbackBase = Duration(milliseconds: 1200);
  static const Duration ttsFallbackPerWord = Duration(milliseconds: 320);
  static const Duration ttsFallbackMax = Duration(seconds: 14);
}

class AppTtsConstants {
  static const double speechRate = 0.90;
  static const double volume = 1.0;
  static const double pitch = 1.1;
  static const String whitespacePattern = r'\s+';
}

class AppDimens {
  static const double minTouchTarget = 48;
  static const double pagePadding = 20;
  static const double sectionGap = 24;
  static const double itemGap = 14;
  static const double smallGap = 8;
  static const double borderRadius = 8;
  static const double bodyText = 18;
  static const double fieldText = 20;
  static const double answerText = 26;
  static const double titleText = 30;
  static const double iconLarge = 34;
  static const double iconMedium = 28;
  static const double micButtonSize = 64;
  static const double micIconSize = 36;
  static const double imagePreviewHeight = 320;
  static const double maxContentWidth = 720;
  static const double progressSize = 56;
  static const double buttonVerticalPadding = 18;
  static const double buttonHorizontalPadding = 18;
  static const double bannerBorderWidth = 2;
  static const int textFieldMinLines = 2;
  static const int textFieldMaxLines = 4;
  static const double micPulseMinScale = 0.88;
  static const double micPulseMaxScale = 1.12;
  static const double appBarElevation = 0;
  static const double blurSigma = 0;
}

class AppNumberConstants {
  static const double percentMultiplier = 100;
  static const double percentMin = 0;
  static const double percentMax = 100;
  static const int percentDigits = 0;
  static const String percentSymbol = '%';
}

class AppColors {
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceAlt = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE7E7E7);
  static const Color accent = Color(0xFFFFD84D);
  static const Color accentDark = Color(0xFF7A5A00);
  static const Color danger = Color(0xFFB00020);
  static const Color dangerSurface = Color(0xFF3A000A);
  static const Color success = Color(0xFF00D084);
  static const Color focus = Color(0xFF64B5F6);
}

class PickerConstants {
  static const double maxWidth = 1280;
  static const double maxHeight = 1280;
  static const int imageQuality = 85;
}

class QualityMathConstants {
  static const int firstInnerPixel = 1;
  static const int minLaplacianDimension = 3;
  static const int laplacianCenterWeight = 4;
  static const double emptyMetric = 0;
  static const double varianceFloor = 0;
}

enum AppLanguage { en, es, fr }

enum GateFlaw { blur, dark, bright }

enum AppTextKey {
  chooseLanguageTitle,
  chooseLanguagePrompt,
  englishButton,
  spanishButton,
  frenchButton,
  takePhotoToGetStarted,
  cameraButton,
  galleryButton,
  settingsLabel,
  openSettings,
  evaluationBanner,
  checkingPhoto,
  photoLooksGoodAskQuestion,
  selectedPhotoLabel,
  questionFieldLabel,
  questionFieldHint,
  microphoneLabel,
  listeningLabel,
  askButton,
  retakePhotoButton,
  thinking,
  warmingUp,
  answerTitle,
  askAnotherQuestion,
  newPhoto,
  settingsTitle,
  settingsAnnounce,
  languageSettingsLabel,
  gateToggleTitle,
  gateToggleSubtitle,
  couldNotHear,
  snackbarTitle,
  noPhotoError,
  emptyQuestionError,
  genericError,
  timeoutError,
  networkError,
  serverError,
  invalidResponse,
  languageSaved,
  captureCancelled,
  backButton,
  answerConfidence,
  processingLabel,
  retakeTitle,
  gateDisabledAnnounce,
}

const Map<AppLanguage, String> kLanguageCodes = <AppLanguage, String>{
  AppLanguage.en: 'en',
  AppLanguage.es: 'es',
  AppLanguage.fr: 'fr',
};

const Map<AppLanguage, String> kTtsLanguageCodes = <AppLanguage, String>{
  AppLanguage.en: 'en-US',
  AppLanguage.es: 'es-ES',
  AppLanguage.fr: 'fr-FR',
};

const Map<AppLanguage, String> kSpeechLanguageCodes = <AppLanguage, String>{
  AppLanguage.en: 'en-US',
  AppLanguage.es: 'es-ES',
  AppLanguage.fr: 'fr-FR',
};

const Map<AppLanguage, Map<AppTextKey, String>> kLocalizedText =
    <AppLanguage, Map<AppTextKey, String>>{
  AppLanguage.en: <AppTextKey, String>{
    AppTextKey.chooseLanguageTitle: 'Choose your language',
    AppTextKey.chooseLanguagePrompt: 'Choose your language to begin.',
    AppTextKey.englishButton: '🇬🇧 English',
    AppTextKey.spanishButton: '🇪🇸 Español',
    AppTextKey.frenchButton: '🇫🇷 Français',
    AppTextKey.takePhotoToGetStarted: 'Take a photo to get started',
    AppTextKey.cameraButton: 'Camera',
    AppTextKey.galleryButton: 'Gallery',
    AppTextKey.settingsLabel: 'Settings',
    AppTextKey.openSettings: 'Open settings',
    AppTextKey.evaluationBanner: '⚠️ Gate disabled — evaluation mode',
    AppTextKey.checkingPhoto: 'Checking photo quality',
    AppTextKey.photoLooksGoodAskQuestion:
        'Photo looks good. Now ask your question.',
    AppTextKey.selectedPhotoLabel: 'Selected photo preview',
    AppTextKey.questionFieldLabel: 'Question',
    AppTextKey.questionFieldHint: 'Type your question here',
    AppTextKey.microphoneLabel: 'Use microphone',
    AppTextKey.listeningLabel: 'Listening',
    AppTextKey.askButton: 'Ask',
    AppTextKey.retakePhotoButton: 'Retake photo',
    AppTextKey.thinking: 'Thinking...',
    AppTextKey.warmingUp: 'Warming up, please wait',
    AppTextKey.answerTitle: 'Answer',
    AppTextKey.askAnotherQuestion: 'Ask another question',
    AppTextKey.newPhoto: 'New photo',
    AppTextKey.settingsTitle: 'Settings',
    AppTextKey.settingsAnnounce: 'Settings',
    AppTextKey.languageSettingsLabel: 'Language',
    AppTextKey.gateToggleTitle: 'Evaluation mode (disable quality gate)',
    AppTextKey.gateToggleSubtitle:
        'When enabled, every photo is sent directly to the cloud.',
    AppTextKey.couldNotHear: 'Could not hear you, please type instead',
    AppTextKey.snackbarTitle: 'Notice',
    AppTextKey.noPhotoError: 'Please take a photo first.',
    AppTextKey.emptyQuestionError: 'Please enter a question.',
    AppTextKey.genericError: 'Something went wrong. Please try again.',
    AppTextKey.timeoutError:
        'The request took too long. Please try again in a moment.',
    AppTextKey.networkError:
        'The internet connection is unavailable. Please try again.',
    AppTextKey.serverError:
        'The assistant service is not available right now. Please try again.',
    AppTextKey.invalidResponse:
        'The assistant returned an unexpected response. Please try again.',
    AppTextKey.languageSaved: 'Language saved.',
    AppTextKey.captureCancelled: 'No photo selected.',
    AppTextKey.backButton: 'Back',
    AppTextKey.answerConfidence: 'Confidence',
    AppTextKey.processingLabel: 'Processing your question',
    AppTextKey.retakeTitle: 'Please retake the photo',
    AppTextKey.gateDisabledAnnounce:
        'Evaluation mode is on. The quality gate is disabled.',
  },
  AppLanguage.es: <AppTextKey, String>{
    AppTextKey.chooseLanguageTitle: 'Elige tu idioma',
    AppTextKey.chooseLanguagePrompt: 'Elige tu idioma para comenzar.',
    AppTextKey.englishButton: '🇬🇧 English',
    AppTextKey.spanishButton: '🇪🇸 Español',
    AppTextKey.frenchButton: '🇫🇷 Français',
    AppTextKey.takePhotoToGetStarted: 'Toma una foto para empezar',
    AppTextKey.cameraButton: 'Cámara',
    AppTextKey.galleryButton: 'Galería',
    AppTextKey.settingsLabel: 'Configuración',
    AppTextKey.openSettings: 'Abrir configuración',
    AppTextKey.evaluationBanner: '⚠️ Puerta desactivada — modo evaluación',
    AppTextKey.checkingPhoto: 'Revisando la calidad de la foto',
    AppTextKey.photoLooksGoodAskQuestion:
        'La foto se ve bien. Ahora haz tu pregunta.',
    AppTextKey.selectedPhotoLabel: 'Vista previa de la foto seleccionada',
    AppTextKey.questionFieldLabel: 'Pregunta',
    AppTextKey.questionFieldHint: 'Escribe tu pregunta aquí',
    AppTextKey.microphoneLabel: 'Usar micrófono',
    AppTextKey.listeningLabel: 'Escuchando',
    AppTextKey.askButton: 'Preguntar',
    AppTextKey.retakePhotoButton: 'Tomar otra foto',
    AppTextKey.thinking: 'Pensando...',
    AppTextKey.warmingUp: 'Preparando, por favor espera',
    AppTextKey.answerTitle: 'Respuesta',
    AppTextKey.askAnotherQuestion: 'Hacer otra pregunta',
    AppTextKey.newPhoto: 'Nueva foto',
    AppTextKey.settingsTitle: 'Configuración',
    AppTextKey.settingsAnnounce: 'Configuración',
    AppTextKey.languageSettingsLabel: 'Idioma',
    AppTextKey.gateToggleTitle:
        'Modo evaluación (desactivar control de calidad)',
    AppTextKey.gateToggleSubtitle:
        'Cuando está activado, cada foto se envía directamente a la nube.',
    AppTextKey.couldNotHear: 'No pude escucharte, escribe tu pregunta',
    AppTextKey.snackbarTitle: 'Aviso',
    AppTextKey.noPhotoError: 'Primero toma una foto.',
    AppTextKey.emptyQuestionError: 'Escribe una pregunta.',
    AppTextKey.genericError: 'Algo salió mal. Inténtalo de nuevo.',
    AppTextKey.timeoutError:
        'La solicitud tardó demasiado. Inténtalo de nuevo en un momento.',
    AppTextKey.networkError:
        'No hay conexión a internet. Inténtalo de nuevo.',
    AppTextKey.serverError:
        'El servicio del asistente no está disponible ahora. Inténtalo de nuevo.',
    AppTextKey.invalidResponse:
        'El asistente devolvió una respuesta inesperada. Inténtalo de nuevo.',
    AppTextKey.languageSaved: 'Idioma guardado.',
    AppTextKey.captureCancelled: 'No se seleccionó ninguna foto.',
    AppTextKey.backButton: 'Atrás',
    AppTextKey.answerConfidence: 'Confianza',
    AppTextKey.processingLabel: 'Procesando tu pregunta',
    AppTextKey.retakeTitle: 'Vuelve a tomar la foto',
    AppTextKey.gateDisabledAnnounce:
        'El modo evaluación está activado. El control de calidad está desactivado.',
  },
  AppLanguage.fr: <AppTextKey, String>{
    AppTextKey.chooseLanguageTitle: 'Choisissez votre langue',
    AppTextKey.chooseLanguagePrompt: 'Choisissez votre langue pour commencer.',
    AppTextKey.englishButton: '🇬🇧 English',
    AppTextKey.spanishButton: '🇪🇸 Español',
    AppTextKey.frenchButton: '🇫🇷 Français',
    AppTextKey.takePhotoToGetStarted: 'Prenez une photo pour commencer',
    AppTextKey.cameraButton: 'Appareil photo',
    AppTextKey.galleryButton: 'Galerie',
    AppTextKey.settingsLabel: 'Paramètres',
    AppTextKey.openSettings: 'Ouvrir les paramètres',
    AppTextKey.evaluationBanner: '⚠️ Contrôle désactivé — mode évaluation',
    AppTextKey.checkingPhoto: 'Vérification de la qualité de la photo',
    AppTextKey.photoLooksGoodAskQuestion:
        'La photo est bonne. Posez maintenant votre question.',
    AppTextKey.selectedPhotoLabel: 'Aperçu de la photo sélectionnée',
    AppTextKey.questionFieldLabel: 'Question',
    AppTextKey.questionFieldHint: 'Tapez votre question ici',
    AppTextKey.microphoneLabel: 'Utiliser le microphone',
    AppTextKey.listeningLabel: 'Écoute en cours',
    AppTextKey.askButton: 'Demander',
    AppTextKey.retakePhotoButton: 'Reprendre la photo',
    AppTextKey.thinking: 'Réflexion en cours...',
    AppTextKey.warmingUp: 'Démarrage, veuillez patienter',
    AppTextKey.answerTitle: 'Réponse',
    AppTextKey.askAnotherQuestion: 'Poser une autre question',
    AppTextKey.newPhoto: 'Nouvelle photo',
    AppTextKey.settingsTitle: 'Paramètres',
    AppTextKey.settingsAnnounce: 'Paramètres',
    AppTextKey.languageSettingsLabel: 'Langue',
    AppTextKey.gateToggleTitle:
        'Mode évaluation (désactiver le contrôle qualité)',
    AppTextKey.gateToggleSubtitle:
        'Lorsque cette option est activée, chaque photo est envoyée directement au nuage.',
    AppTextKey.couldNotHear:
        'Je ne vous ai pas entendu, veuillez taper votre question',
    AppTextKey.snackbarTitle: 'Information',
    AppTextKey.noPhotoError: 'Veuillez d’abord prendre une photo.',
    AppTextKey.emptyQuestionError: 'Veuillez saisir une question.',
    AppTextKey.genericError: 'Une erreur est survenue. Veuillez réessayer.',
    AppTextKey.timeoutError:
        'La demande a pris trop de temps. Veuillez réessayer dans un instant.',
    AppTextKey.networkError:
        'La connexion internet est indisponible. Veuillez réessayer.',
    AppTextKey.serverError:
        'Le service assistant est indisponible pour le moment. Veuillez réessayer.',
    AppTextKey.invalidResponse:
        'L’assistant a renvoyé une réponse inattendue. Veuillez réessayer.',
    AppTextKey.languageSaved: 'Langue enregistrée.',
    AppTextKey.captureCancelled: 'Aucune photo sélectionnée.',
    AppTextKey.backButton: 'Retour',
    AppTextKey.answerConfidence: 'Confiance',
    AppTextKey.processingLabel: 'Traitement de votre question',
    AppTextKey.retakeTitle: 'Veuillez reprendre la photo',
    AppTextKey.gateDisabledAnnounce:
        'Le mode évaluation est activé. Le contrôle qualité est désactivé.',
  },
};

const Map<GateFlaw, Map<AppLanguage, String>> kRetakeMessages =
    <GateFlaw, Map<AppLanguage, String>>{
  GateFlaw.blur: <AppLanguage, String>{
    AppLanguage.en:
        'The photo is too blurry. Please hold steady and try again.',
    AppLanguage.es:
        'La foto está borrosa. Mantén el teléfono firme e inténtalo de nuevo.',
    AppLanguage.fr:
        'La photo est floue. Tenez le téléphone stable et réessayez.',
  },
  GateFlaw.dark: <AppLanguage, String>{
    AppLanguage.en:
        'The photo is too dark. Move to a brighter place and try again.',
    AppLanguage.es:
        'La foto está muy oscura. Ve a un lugar más iluminado e inténtalo de nuevo.',
    AppLanguage.fr:
        'La photo est trop sombre. Allez dans un endroit plus lumineux et réessayez.',
  },
  GateFlaw.bright: <AppLanguage, String>{
    AppLanguage.en:
        'The photo is too bright. Move away from direct light and try again.',
    AppLanguage.es:
        'La foto está muy brillante. Aléjate de la luz directa e inténtalo de nuevo.',
    AppLanguage.fr:
        'La photo est trop lumineuse. Éloignez-vous de la lumière directe et réessayez.',
  },
};

String localized(AppLanguage language, AppTextKey key) {
  return kLocalizedText[language]?[key] ??
      kLocalizedText[AppLanguage.en]![key]!;
}

String retakeMessage(AppLanguage language, GateFlaw flaw) {
  return kRetakeMessages[flaw]?[language] ??
      kRetakeMessages[flaw]![AppLanguage.en]!;
}

String languageCode(AppLanguage language) {
  return kLanguageCodes[language] ?? kLanguageCodes[AppLanguage.en]!;
}

String ttsLanguageCode(AppLanguage language) {
  return kTtsLanguageCodes[language] ?? kTtsLanguageCodes[AppLanguage.en]!;
}

String speechLanguageCode(AppLanguage language) {
  return kSpeechLanguageCodes[language] ??
      kSpeechLanguageCodes[AppLanguage.en]!;
}

AppLanguage languageFromCode(String? code) {
  for (final MapEntry<AppLanguage, String> entry in kLanguageCodes.entries) {
    if (entry.value == code) {
      return entry.key;
    }
  }
  return AppLanguage.en;
}

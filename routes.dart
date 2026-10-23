import 'package:get/get.dart';

import '../constants.dart';
import '../screens/answer_screen.dart';
import '../screens/home_screen.dart';
import '../screens/language_select_screen.dart';
import '../screens/processing_screen.dart';
import '../screens/retake_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String language = kRouteLanguage;
  static const String home = kRouteHome;
  static const String processing = kRouteProcessing;
  static const String retake = kRouteRetake;
  static const String answer = kRouteAnswer;
  static const String settings = kRouteSettings;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: language,
      page: () => const LanguageSelectScreen(),
    ),
    GetPage<dynamic>(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage<dynamic>(
      name: processing,
      page: () => const ProcessingScreen(),
    ),
    GetPage<dynamic>(
      name: retake,
      page: () => const RetakeScreen(),
    ),
    GetPage<dynamic>(
      name: answer,
      page: () => const AnswerScreen(),
    ),
    GetPage<dynamic>(
      name: settings,
      page: () => const SettingsScreen(),
    ),
  ];
}

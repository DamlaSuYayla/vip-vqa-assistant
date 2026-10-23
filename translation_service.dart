import 'package:dio/dio.dart';

import '../constants.dart';

class TranslationService {
  TranslationService()
      : dio = Dio(
          BaseOptions(
            connectTimeout: AppDurations.hfTimeout,
            receiveTimeout: AppDurations.hfTimeout,
            sendTimeout: AppDurations.hfTimeout,
          ),
        );

  final Dio dio;

  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    if (from == to || text.trim().isEmpty) {
      return text;
    }
    try {
      final String langPair = '$from|$to';
      final String encodedText = Uri.encodeComponent(text);
      final String url = 'https://api.mymemory.translated.net/get'
          '?q=$encodedText&langpair=$langPair';
      final Response<dynamic> response = await dio.get<dynamic>(url);
      if (response.statusCode == 200) {
        return response.data['responseData']['translatedText'] as String? ??
            text;
      }
      return text;
    } catch (_) {
      return text;
    }
  }

  void close() {
    dio.close();
  }
}

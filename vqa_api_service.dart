import 'package:dio/dio.dart';

import '../constants.dart';
import '../models/vqa_answer.dart';

class VqaApiException implements Exception {
  const VqaApiException(this.messageKey);

  final AppTextKey messageKey;
}

class VqaApiService {
  VqaApiService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: AppDurations.hfTimeout,
            receiveTimeout: AppDurations.hfTimeout,
            sendTimeout: AppDurations.hfTimeout,
            headers: const <String, String>{
              kHeaderContentType: kHeaderApplicationJson,
            },
          ),
        );

  final Dio _dio;

  Future<VqaAnswer> ask({
    required String base64Image,
    required String englishQuestion,
  }) async {
    try {
      final Response<Object?> response = await _dio.post<Object?>(
        '/.netlify/functions/vqa',
        data: <String, String>{
          kJsonImage: base64Image,
          kJsonQuestion: englishQuestion,
        },
      );
      return _parseResponse(response.data);
    } on DioException catch (error) {
      throw VqaApiException(_messageKeyForDioError(error));
    } catch (_) {
      throw const VqaApiException(AppTextKey.genericError);
    }
  }

  VqaAnswer _parseResponse(Object? data) {
    if (data is! Map) {
      throw const VqaApiException(AppTextKey.invalidResponse);
    }

    final Object? answerValue = data[kJsonAnswer];
    if (answerValue is! String || answerValue.trim().isEmpty) {
      throw const VqaApiException(AppTextKey.invalidResponse);
    }

    return VqaAnswer(
      answer: answerValue,
      confidence: _readConfidence(data[kJsonConfidence]),
    );
  }

  double _readConfidence(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? QualityMathConstants.emptyMetric;
    }
    return QualityMathConstants.emptyMetric;
  }

  AppTextKey _messageKeyForDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppTextKey.timeoutError;
      case DioExceptionType.badResponse:
        return AppTextKey.serverError;
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return AppTextKey.networkError;
      default:
        return AppTextKey.genericError;
    }
  }

  void close() {
    _dio.close();
  }
}

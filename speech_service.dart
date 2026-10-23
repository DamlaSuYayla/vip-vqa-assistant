import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';

class SpeechService {
  Future<String?> startListening(String languageCode) async {
    if (!kIsWeb) {
      return null;
    }

    final langMap = {'en': 'en-US', 'es': 'es-ES', 'fr': 'fr-FR'};
    final lang = langMap[languageCode] ?? 'en-US';

    final completer = Completer<String?>();

    try {
      globalContext.callMethodVarArgs('startSpeechRecognition'.toJS, [
        lang.toJS,
        (JSString result) {
          completer.complete(result.toDart);
        }.toJS,
        (JSString error) {
          completer.complete(null);
        }.toJS,
      ]);
    } catch (e) {
      return null;
    }

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
  }
}

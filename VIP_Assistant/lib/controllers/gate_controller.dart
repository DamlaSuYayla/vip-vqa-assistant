import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../models/gate_result.dart';
import '../services/quality_gate_service.dart';

class GateController extends GetxController {
  GateController(this._qualityGateService);

  final QualityGateService _qualityGateService;

  final RxBool isEvaluating = false.obs;
  final Rxn<GateResult> lastResult = Rxn<GateResult>();

  int gateLatencyMs = 0;

  Future<GateResult> evaluate(Uint8List bytes) async {
    isEvaluating.value = true;
    try {
      final Stopwatch gateStopwatch = Stopwatch()..start();
      final GateResult result = await _qualityGateService.evaluate(bytes);
      gateStopwatch.stop();
      gateLatencyMs = gateStopwatch.elapsedMilliseconds;
      lastResult.value = result;
      await _hapticForResult(result);
      return result;
    } catch (_) {
      const GateResult result = GateResult.failed(flaw: GateFlaw.blur);
      lastResult.value = result;
      await _hapticForResult(result);
      return result;
    } finally {
      isEvaluating.value = false;
    }
  }

  Future<void> assumePassed() async {
    gateLatencyMs = 0;
    const GateResult result = GateResult.passed();
    lastResult.value = result;
    await _hapticForResult(result);
  }

  void clear() {
    lastResult.value = null;
  }

  Future<void> _hapticForResult(GateResult result) async {
    if (!kIsWeb) {
      return;
    }
    try {
      if (result.passed) {
        await HapticFeedback.lightImpact();
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      // Haptics are not supported by every browser.
    }
  }

}

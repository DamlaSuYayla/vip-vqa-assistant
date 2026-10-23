import '../constants.dart';

class GateResult {
  const GateResult({
    required this.passed,
    this.flaw,
    this.blurVariance,
    this.meanBrightness,
    this.brightFraction,
  });

  const GateResult.passed({
    this.blurVariance,
    this.meanBrightness,
    this.brightFraction,
  })  : passed = true,
        flaw = null;

  const GateResult.failed({
    required this.flaw,
    this.blurVariance,
    this.meanBrightness,
    this.brightFraction,
  }) : passed = false;

  final bool passed;
  final GateFlaw? flaw;
  final double? blurVariance;
  final double? meanBrightness;
  final double? brightFraction;
}

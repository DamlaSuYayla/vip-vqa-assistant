class VqaAnswer {
  const VqaAnswer({
    required this.answer,
    required this.confidence,
    this.gateLatencyMs = 0,
    this.apiLatencyMs = 0,
    this.totalLatencyMs = 0,
  });

  final String answer;
  final double confidence;
  final int gateLatencyMs;
  final int apiLatencyMs;
  final int totalLatencyMs;

  VqaAnswer copyWith({
    String? answer,
    double? confidence,
    int? gateLatencyMs,
    int? apiLatencyMs,
    int? totalLatencyMs,
  }) {
    return VqaAnswer(
      answer: answer ?? this.answer,
      confidence: confidence ?? this.confidence,
      gateLatencyMs: gateLatencyMs ?? this.gateLatencyMs,
      apiLatencyMs: apiLatencyMs ?? this.apiLatencyMs,
      totalLatencyMs: totalLatencyMs ?? this.totalLatencyMs,
    );
  }
}

class ValidationIssue {
  final String id;
  final String type; // 'error' | 'warning'
  final String ruleId;
  final String message;
  final String? shapeId;
  final String status; // 'pending' | 'fixed' | 'unfixable'
  AiSuggestionData? aiSuggestion;

  ValidationIssue({
    required this.id,
    required this.type,
    required this.ruleId,
    required this.message,
    this.shapeId,
    this.status = 'pending',
    this.aiSuggestion,
  });

  factory ValidationIssue.fromJson(Map<String, dynamic> json) {
    return ValidationIssue(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'warning',
      ruleId: json['ruleId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      shapeId: json['shapeId']?.toString(),
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

class ValidationSummary {
  final int errors;
  final int warnings;
  final int total;

  const ValidationSummary({required this.errors, required this.warnings, required this.total});

  factory ValidationSummary.fromJson(Map<String, dynamic> json) {
    return ValidationSummary(
      errors: (json['errors'] as num?)?.toInt() ?? 0,
      warnings: (json['warnings'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class ValidationResult {
  final ValidationSummary summary;
  final double score;
  final List<ValidationIssue> issues;
  final String timestamp;

  const ValidationResult({
    required this.summary,
    required this.score,
    required this.issues,
    required this.timestamp,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return ValidationResult(
      summary: ValidationSummary.fromJson(data['summary'] ?? {}),
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
      issues: (data['issues'] as List<dynamic>? ?? [])
          .map((i) => ValidationIssue.fromJson(i as Map<String, dynamic>))
          .toList(),
      timestamp: data['timestamp']?.toString() ?? '',
    );
  }
}

class AutofixResult {
  final double beforeScore;
  final double afterScore;
  final double improvement;
  final int fixedCount;
  final List<dynamic> shapes;
  final List<ValidationIssue> issuesWithStatus;

  const AutofixResult({
    required this.beforeScore,
    required this.afterScore,
    required this.improvement,
    required this.fixedCount,
    required this.shapes,
    required this.issuesWithStatus,
  });

  factory AutofixResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AutofixResult(
      beforeScore: (data['before']?['score'] as num?)?.toDouble() ?? 0.0,
      afterScore: (data['after']?['score'] as num?)?.toDouble() ?? 0.0,
      improvement: (data['improvement'] as num?)?.toDouble() ?? 0.0,
      fixedCount: (data['fixedCount'] as num?)?.toInt() ?? 0,
      shapes: data['after']?['shapes'] as List<dynamic>? ?? [],
      issuesWithStatus: (data['issuesWithStatus'] as List<dynamic>? ?? [])
          .map((i) => ValidationIssue.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AiSuggestionData {
  final String explanation;
  final List<String> steps;
  final double? confidence;

  const AiSuggestionData({
    required this.explanation,
    required this.steps,
    this.confidence,
  });

  factory AiSuggestionData.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] ?? json['actionableSteps'] ?? [];
    return AiSuggestionData(
      explanation: json['explanation']?.toString() ?? json['summary']?.toString() ?? '',
      steps: List<String>.from(rawSteps is List ? rawSteps : []),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

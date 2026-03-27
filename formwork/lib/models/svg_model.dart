class SvgIssue {
  final String id;
  final String type;
  final String severity;
  final String element;
  final String explanation;
  final String fix;

  const SvgIssue({
    required this.id,
    required this.type,
    required this.severity,
    required this.element,
    required this.explanation,
    required this.fix,
  });

  factory SvgIssue.fromJson(Map<String, dynamic> json) => SvgIssue(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        severity: json['severity']?.toString() ?? 'Low',
        element: json['element']?.toString() ?? '',
        explanation: json['explanation']?.toString() ?? '',
        fix: json['fix']?.toString() ?? '',
      );
}

class SvgScore {
  final double before;
  final double after;
  const SvgScore({required this.before, required this.after});

  factory SvgScore.fromJson(Map<String, dynamic> json) => SvgScore(
        before: (json['before'] as num?)?.toDouble() ?? 100,
        after: (json['after'] as num?)?.toDouble() ?? 100,
      );
}

class SvgAnalysisResult {
  final String status;
  final int issuesFound;
  final List<SvgIssue> issues;
  final String fixedSvg;
  final List<String> fixLog;
  final int fixesApplied;
  final int remainingIssues;
  final List<String> suggestions;
  final String originalSvg;
  final SvgScore score;
  final int elementsCount;

  const SvgAnalysisResult({
    required this.status,
    required this.issuesFound,
    required this.issues,
    required this.fixedSvg,
    required this.fixLog,
    required this.fixesApplied,
    required this.remainingIssues,
    required this.suggestions,
    required this.originalSvg,
    required this.score,
    required this.elementsCount,
  });

  factory SvgAnalysisResult.fromJson(Map<String, dynamic> json, String originalSvg) =>
      SvgAnalysisResult(
        status: json['status']?.toString() ?? 'error',
        issuesFound: (json['issues_found'] as num?)?.toInt() ?? 0,
        issues: (json['issues'] as List<dynamic>? ?? [])
            .map((e) => SvgIssue.fromJson(e as Map<String, dynamic>))
            .toList(),
        fixedSvg: json['fixed_svg']?.toString() ?? originalSvg,
        fixLog: List<String>.from(json['fix_log'] as List<dynamic>? ?? []),
        fixesApplied: (json['fixes_applied'] as num?)?.toInt() ?? 0,
        remainingIssues: (json['remaining_issues'] as num?)?.toInt() ?? 0,
        suggestions: List<String>.from(json['suggestions'] as List<dynamic>? ?? []),
        originalSvg: originalSvg,
        score: SvgScore.fromJson(json['score'] as Map<String, dynamic>? ?? {}),
        elementsCount: (json['elements_count'] as num?)?.toInt() ?? 0,
      );
}

class SvgCard {
  final String id;
  final String filename;
  final String originalSvg;
  SvgAnalysisResult? result;
  bool isLoading;
  String? error;

  SvgCard({
    required this.id,
    required this.filename,
    required this.originalSvg,
    this.result,
    this.isLoading = false,
    this.error,
  });
}

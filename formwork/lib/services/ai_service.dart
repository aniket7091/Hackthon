import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/validation_model.dart';

class AiService {
  final _client = ApiClient();

  /// Get an AI suggestion for a specific validation issue.
  Future<AiSuggestionData> getSuggestion(ValidationIssue issue) async {
    final json = await _client.post(ApiConstants.aiSuggest, {
      'issue': {
        'id': issue.id,
        'type': issue.type,
        'ruleId': issue.ruleId,
        'message': issue.message,
        'shapeId': issue.shapeId,
      }
    });
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final suggestion = data['suggestion'] as Map<String, dynamic>? ?? {};
    return AiSuggestionData.fromJson(suggestion);
  }
}

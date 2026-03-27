import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/validation_model.dart';

class ValidationService {
  final _client = ApiClient();

  /// Validate a design JSON and receive issues + score.
  Future<ValidationResult> validate(Map<String, dynamic> designJson) async {
    final json = await _client.post(ApiConstants.validate, designJson);
    return ValidationResult.fromJson(json);
  }
}

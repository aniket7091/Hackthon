import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/validation_model.dart';

class AutofixService {
  final _client = ApiClient();

  /// Auto-fix a design and receive before/after comparison.
  Future<AutofixResult> autofix(Map<String, dynamic> designJson) async {
    final json = await _client.post(ApiConstants.autofix, designJson);
    return AutofixResult.fromJson(json);
  }
}

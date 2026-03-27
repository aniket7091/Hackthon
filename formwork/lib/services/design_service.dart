import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/design_model.dart';

class DesignService {
  final _client = ApiClient();

  /// Upload a raw design JSON and receive parsed shapes + metadata.
  Future<DesignUploadResponse> uploadDesign(Map<String, dynamic> designJson) async {
    final json = await _client.post(ApiConstants.upload, designJson);
    return DesignUploadResponse.fromJson(json);
  }
}

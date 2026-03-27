import 'dart:typed_data';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';

class ReportService {
  final _client = ApiClient();

  /// Generate a PDF report for the given design and return raw bytes.
  Future<Uint8List> generateReport(Map<String, dynamic> designJson) async {
    return _client.postBytes(ApiConstants.report, designJson);
  }
}

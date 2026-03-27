import '../core/network/api_client.dart';

class SvgService {
  final _client = ApiClient();

  Future<Map<String, dynamic>> analyzeSvg(String svgContent) async {
    return _client.post(
      '/api/svg/analyze',
      {'svgContent': svgContent},
      withAuth: true,
    );
  }
}

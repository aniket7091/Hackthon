class ApiConstants {
  static const String baseUrl = 'https://designguard-backend-pv4z.onrender.com';

  // Auth
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';

  // Design
  static const String upload = '/api/design/upload';
  static const String validate = '/api/design/validate';
  static const String autofix = '/api/design/autofix';
  static const String report = '/api/design/report';
  static const String aiSuggest = '/api/design/ai-suggest';
  static const String health = '/health';
}

class AppConstants {
  AppConstants._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'your-gemini-key',
  );

  static const String zinnipayBaseUrl = 'https://api.zinnipay.com/v1';
  static const String zinnipayApiKey = String.fromEnvironment(
    'ZINNIPAY_API_KEY',
    defaultValue: 'your-zinnipay-key',
  );

  static const int acceleratorPriceBDT = 2999;
  static const int acceleratorTotalDays = 30;
  static const int maxConversationContextMessages = 20;
  static const int sessionTimerDefaultMinutes = 15;
  static const String appDeepLinkScheme = 'boloo';
}

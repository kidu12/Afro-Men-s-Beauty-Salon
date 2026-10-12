import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyUserId = 'afro_user_id';
  static const String _keyUserRole = 'afro_user_role';
  static const String _keyUserName = 'afro_user_name';
  static const String _keyUserEmail = 'afro_user_email';
  static const String _keyUserAvatar = 'afro_user_avatar';
  static const String _keyFavorites = 'afro_favorites';
  static const String _keyOnboardingDone = 'afro_onboarding_done';
  static const String _keyAuthToken = 'afro_auth_jwt_token';
  static const String _keyLanguage = 'afro_user_language';
  static const String _keyTheme = 'afro_user_theme';
  static const String _keyServerBaseUrl = 'afro_server_base_url';

  static SharedPreferences? _staticPrefs;
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs) {
    _staticPrefs = _prefs;
  }

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    _staticPrefs = prefs;
    return LocalStorageService(prefs);
  }

  static Future<String?> getToken() async {
    _staticPrefs ??= await SharedPreferences.getInstance();
    return _staticPrefs?.getString(_keyAuthToken);
  }

  static Future<void> saveToken(String token) async {
    _staticPrefs ??= await SharedPreferences.getInstance();
    await _staticPrefs?.setString(_keyAuthToken, token);
  }

  static Future<void> clearToken() async {
    _staticPrefs ??= await SharedPreferences.getInstance();
    await _staticPrefs?.remove(_keyAuthToken);
  }

  // Language & Theme preferences
  String get savedLanguage => _prefs.getString(_keyLanguage) ?? 'am';
  Future<void> setSavedLanguage(String code) => _prefs.setString(_keyLanguage, code);

  String get savedTheme => _prefs.getString(_keyTheme) ?? 'luxury_gold';
  Future<void> setSavedTheme(String themeKey) => _prefs.setString(_keyTheme, themeKey);

  String? get savedServerBaseUrl => _prefs.getString(_keyServerBaseUrl);
  Future<void> setSavedServerBaseUrl(String url) => _prefs.setString(_keyServerBaseUrl, url);
  Future<void> clearSavedServerBaseUrl() => _prefs.remove(_keyServerBaseUrl);

  bool get isOnboardingCompleted => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingCompleted(bool value) => _prefs.setBool(_keyOnboardingDone, value);

  String? get savedUserId => _prefs.getString(_keyUserId);
  String? get savedUserRole => _prefs.getString(_keyUserRole);
  String? get savedUserName => _prefs.getString(_keyUserName);
  String? get savedUserEmail => _prefs.getString(_keyUserEmail);
  String? get savedUserAvatar => _prefs.getString(_keyUserAvatar);

  Future<void> saveUserSession({
    required String id,
    required String role,
    required String name,
    String? email,
    String? avatarUrl,
  }) async {
    await _prefs.setString(_keyUserId, id);
    await _prefs.setString(_keyUserRole, role);
    await _prefs.setString(_keyUserName, name);
    if (email != null) await _prefs.setString(_keyUserEmail, email);
    if (avatarUrl != null) await _prefs.setString(_keyUserAvatar, avatarUrl);
  }

  Future<void> clearUserSession() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserAvatar);
  }

  List<String> getFavorites() => _prefs.getStringList(_keyFavorites) ?? [];

  Future<void> toggleFavorite(String itemKey) async {
    final list = getFavorites();
    if (list.contains(itemKey)) {
      list.remove(itemKey);
    } else {
      list.add(itemKey);
    }
    await _prefs.setStringList(_keyFavorites, list);
  }

  bool isFavorite(String itemKey) => getFavorites().contains(itemKey);
}

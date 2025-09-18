import 'package:shared_preferences/shared_preferences.dart';

/// Token storage service using SharedPreferences
class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';

  static TokenStorage? _instance;
  static TokenStorage get instance => _instance ??= TokenStorage._internal();
  TokenStorage._internal();

  SharedPreferences? _prefs;

  /// Initialize the token storage
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Store authentication token
  Future<bool> storeToken(String token) async {
    if (_prefs == null) await initialize();
    return await _prefs!.setString(_tokenKey, token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    if (_prefs == null) await initialize();
    return _prefs!.getString(_tokenKey);
  }

  /// Store refresh token
  Future<bool> storeRefreshToken(String refreshToken) async {
    if (_prefs == null) await initialize();
    return await _prefs!.setString(_refreshTokenKey, refreshToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    if (_prefs == null) await initialize();
    return _prefs!.getString(_refreshTokenKey);
  }

  /// Store user data as JSON string
  Future<bool> storeUserData(Map<String, dynamic> userData) async {
    if (_prefs == null) await initialize();
    return await _prefs!.setString(_userDataKey, userData.toString());
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    if (_prefs == null) await initialize();
    final userDataString = _prefs!.getString(_userDataKey);
    if (userDataString == null) return null;
    
    // Simple parsing - in production, use proper JSON parsing
    try {
      // This is a simplified approach. In production, use jsonEncode/jsonDecode
      return {'raw_data': userDataString};
    } catch (e) {
      return null;
    }
  }

  /// Store individual user fields for quick access
  Future<bool> storeUserFields({
    required String userId,
    required String email,
    required String name,
    required String phone,
  }) async {
    if (_prefs == null) await initialize();
    
    final results = await Future.wait([
      _prefs!.setString(_userIdKey, userId),
      _prefs!.setString(_userEmailKey, email),
      _prefs!.setString(_userNameKey, name),
      _prefs!.setString(_userPhoneKey, phone),
    ]);
    
    return results.every((result) => result);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    if (_prefs == null) await initialize();
    return _prefs!.getString(_userIdKey);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    if (_prefs == null) await initialize();
    return _prefs!.getString(_userEmailKey);
  }

  /// Get user name
  Future<String?> getUserName() async {
    if (_prefs == null) await initialize();
    return _prefs!.getString(_userNameKey);
  }

  /// Get user phone
  Future<String?> getUserPhone() async {
    if (_prefs == null) await initialize();
    return _prefs!.getString(_userPhoneKey);
  }

  /// Set login status
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    if (_prefs == null) await initialize();
    return await _prefs!.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    if (_prefs == null) await initialize();
    return _prefs!.getBool(_isLoggedInKey) ?? false;
  }

  /// Clear all stored data (logout)
  Future<bool> clearAll() async {
    if (_prefs == null) await initialize();
    
    final results = await Future.wait([
      _prefs!.remove(_tokenKey),
      _prefs!.remove(_refreshTokenKey),
      _prefs!.remove(_userDataKey),
      _prefs!.remove(_isLoggedInKey),
      _prefs!.remove(_userIdKey),
      _prefs!.remove(_userEmailKey),
      _prefs!.remove(_userNameKey),
      _prefs!.remove(_userPhoneKey),
    ]);
    
    return results.every((result) => result);
  }

  /// Clear only tokens (keep user data)
  Future<bool> clearTokens() async {
    if (_prefs == null) await initialize();
    
    final results = await Future.wait([
      _prefs!.remove(_tokenKey),
      _prefs!.remove(_refreshTokenKey),
    ]);
    
    return results.every((result) => result);
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get all stored keys (for debugging)
  Future<Set<String>> getAllKeys() async {
    if (_prefs == null) await initialize();
    return _prefs!.getKeys();
  }

  /// Store login session data
  Future<bool> storeLoginSession({
    required String token,
    required String userId,
    required String email,
    required String name,
    required String phone,
    String? refreshToken,
  }) async {
    if (_prefs == null) await initialize();
    
    final results = await Future.wait([
      storeToken(token),
      storeUserFields(userId: userId, email: email, name: name, phone: phone),
      setLoggedIn(true),
      if (refreshToken != null) storeRefreshToken(refreshToken),
    ]);
    
    return results.every((result) => result);
  }
}

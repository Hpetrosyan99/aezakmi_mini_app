import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class _Preferences {
  _Preferences._();

  static const authToken = 'authToken';
  static const skippedAppVersion = 'skippedAppVersion';
}

class StorageUtils {
  StorageUtils._();
  static Future<SharedPreferences> get sharedInstance => SharedPreferences.getInstance();

  static Future<String?> getAccessToken() async {
    return _getString(_Preferences.authToken);
  }

  static Future<void> setAccessToken(String authToken) async {
    await _setString(_Preferences.authToken, authToken);
  }

  static Future<void> removeAccessToken() async {
    return _remove(_Preferences.authToken);
  }

  static Future<bool> isLoggedIn() async {
    final accessToken = await StorageUtils.getAccessToken();
    return accessToken != null;
  }

  /// New version
  static Future<void> setSkippedAppVersion(String storeVersion) async {
    await _setString(_Preferences.skippedAppVersion, storeVersion);
  }

  static Future<String?> getSkippedAppVersion() {
    return _getString(_Preferences.skippedAppVersion);
  }

  static Future<void> _remove(String key) async {
    final prefs = await sharedInstance;
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await sharedInstance;
    await prefs.clear();
  }

  static Future<void> _setString(String key, String value) async {
    final prefs = await sharedInstance;
    await prefs.setString(key, value);
  }

  static Future<String?> _getString(String key) async {
    final prefs = await sharedInstance;
    return prefs.getString(key);
  }
}

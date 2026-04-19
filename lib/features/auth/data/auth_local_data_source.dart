import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  static const String _authKey = 'tasksync.is_authenticated';

  bool get isAuthenticated => _preferences.getBool(_authKey) ?? false;

  Future<void> setAuthenticated(bool value) {
    return _preferences.setBool(_authKey, value);
  }
}

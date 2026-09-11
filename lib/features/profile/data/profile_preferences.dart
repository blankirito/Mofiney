import 'package:shared_preferences/shared_preferences.dart';

class ProfilePreferences {
  static const _displayNameKey = 'profile_display_name';
  static const defaultDisplayName = 'Mofiney User';

  Future<String> loadDisplayName() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_displayNameKey) ?? defaultDisplayName;
  }

  Future<void> saveDisplayName(String displayName) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_displayNameKey, displayName);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  // Pour récupérer une instance facilement
  static Future<SharedPreferences> get instance async =>
      await SharedPreferences.getInstance();

  // Clés utilisées
  static const String keyIsDarkMode = 'isDarkMode';

  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';
  static const String keyUsername = 'username';
  static const String keyEmail = 'email';
  static const String keyImgProfile = 'imgProfile';
}

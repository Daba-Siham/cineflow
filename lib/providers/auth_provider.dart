import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cineflow/data/services/auth_service.dart';
import 'package:cineflow/core/storage/prefs.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool _isLoggedIn = false;
  int? _userId;
  String? _username;
  String? _email;
  String? _imgProfile;

  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId;
  String get username => _username ?? 'Utilisateur';
  String? get email => _email;
  String? get imgProfile => _imgProfile;

  // ---------- INIT : charger depuis SharedPreferences ----------
  Future<void> init() async {
    final prefs = await AppPrefs.instance;

    final savedLoggedIn = prefs.getBool(AppPrefs.keyIsLoggedIn) ?? false;
    final savedId = prefs.getInt(AppPrefs.keyUserId);

    if (!savedLoggedIn || savedId == null) {
      // Pas de user sauvegardé
      _isLoggedIn = false;
      return;
    }

    _isLoggedIn = true;
    _userId = savedId;
    _username = prefs.getString(AppPrefs.keyUsername);
    _email = prefs.getString(AppPrefs.keyEmail);
    _imgProfile = prefs.getString(AppPrefs.keyImgProfile);

    notifyListeners();
  }

  // ---------- Sauvegarde dans SharedPreferences ----------
  Future<void> _saveToPrefs() async {
    final prefs = await AppPrefs.instance;

    if (_userId == null) {
      await prefs.setBool(AppPrefs.keyIsLoggedIn, false);
      return;
    }

    await prefs.setBool(AppPrefs.keyIsLoggedIn, _isLoggedIn);
    await prefs.setInt(AppPrefs.keyUserId, _userId!);
    await prefs.setString(AppPrefs.keyUsername, _username ?? '');
    await prefs.setString(AppPrefs.keyEmail, _email ?? '');
    await prefs.setString(AppPrefs.keyImgProfile, _imgProfile ?? '');
  }

  // ---------- REGISTER ----------
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password, {
    XFile? image,
  }) async {
    // ⚠️ adapte selon ton AuthService.register (avec ou sans image)
    final result = await _service.register(
      username: username,
      email: email,
      password: password,
      // image: image, // si tu as ajouté ça dans le service
    );

    if (result['success'] == true) {
      final user = result['user'];
      _userId = user['id'];
      _username = user['username'];
      _email = user['email'];
      _imgProfile = user['imgProfile'];
      _isLoggedIn = true;

      await _saveToPrefs();
      notifyListeners();
    }

    return result;
  }

  // ---------- LOGIN ----------
  Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await _service.login(
      username: username,
      password: password,
    );

    if (result['success'] == true) {
      final user = result['user'];

      _userId = user['id'];
      _username = user['username'];
      _email = user['email'];
      _imgProfile = user['imgProfile'];
      _isLoggedIn = true;

      await _saveToPrefs();
      notifyListeners();
    }

    return result;
  }

  // ---------- REFRESH depuis backend ----------
  Future<void> refreshUser() async {
    if (_userId == null) return;

    final user = await _service.getUser(_userId!);
    if (user != null) {
      _username = user['username'];
      _email = user['email'];
      _imgProfile = user['imgProfile'];

      await _saveToPrefs();
      notifyListeners();
    }
  }

  // ---------- UPLOAD AVATAR ----------
  Future<bool> uploadAvatar(XFile image) async {
    if (_userId == null) return false;

    final result = await _service.uploadProfileImage(
      userId: _userId!,
      image: image,
    );

    if (result['statusCode'] == 201) {
      _imgProfile = result['data']['path'];
      await _saveToPrefs();
      notifyListeners();
      return true;
    }

    return false;
  }

  // ---------- LOGOUT ----------
  Future<void> logout() async {
    _isLoggedIn = false;
    _userId = null;
    _username = null;
    _email = null;
    _imgProfile = null;

    final prefs = await AppPrefs.instance;
    await prefs.remove(AppPrefs.keyIsLoggedIn);
    await prefs.remove(AppPrefs.keyUserId);
    await prefs.remove(AppPrefs.keyUsername);
    await prefs.remove(AppPrefs.keyEmail);
    await prefs.remove(AppPrefs.keyImgProfile);

    notifyListeners();
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cineflow/data/services/auth_service.dart';

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

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final result =
        await _service.register(username: username, email: email, password: password);
    return result;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final result =
        await _service.login(username: username, password: password);
    if (result['success'] == true) {
      final user = result['user'];
      _userId = user['id'];
      _username = user['username'];
      _email = user['email'];
      _imgProfile = user['imgProfile'];
      _isLoggedIn = true;
      notifyListeners();
    }
    return result;
  }

  Future<void> refreshUser() async {
    if (_userId == null) return;
    final user = await _service.getUser(_userId!);
    if (user != null) {
      _username = user['username'];
      _email = user['email'];
      _imgProfile = user['imgProfile'];
      notifyListeners();
    }
  }

  Future<void> uploadAvatar(XFile image) async {
    if (_userId == null) return;
    final result =
        await _service.uploadProfileImage(userId: _userId!, image: image);
    if (result['statusCode'] == 201) {
      _imgProfile = result['data']['path'];
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _userId = null;
    _username = null;
    _email = null;
    _imgProfile = null;
    notifyListeners();
  }
}

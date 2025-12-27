import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cineflow/core/constants/api_constants.dart';

class AuthService {
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.authBase}/register');
    final body = {
      'username': username,
      'email': email,
      'password_hash': _hashPassword(password),
    };
    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
    if (res.statusCode == 201) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'message': jsonDecode(res.body)['message'] ?? 'Erreur'
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.authBase}/login_user');
    final body = {
      'username': username,
      'password_hash': _hashPassword(password),
    };
    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {'success': true, 'user': data};
    } else {
      return {
        'success': false,
        'message': jsonDecode(res.body)['message'] ?? 'Erreur'
      };
    }
  }

  Future<Map<String, dynamic>> uploadProfileImage({
    required int userId,
    required XFile image,
  }) async {
    final url =
        Uri.parse('${ApiConstants.authBase}/upload_profile_image/$userId');
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath('image', image.path,
          filename: image.name),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final data = jsonDecode(res.body);
    return {'statusCode': res.statusCode, 'data': data};
  }

  Future<Map<String, dynamic>?> getUser(int userId) async {
    final url = Uri.parse('${ApiConstants.authBase}/user/$userId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }
}

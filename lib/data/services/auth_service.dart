import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cineflow/core/constants/api_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    XFile? image, 
  }) async {
    final url = Uri.parse('${ApiConstants.authBase}/register');

    try {
      final request = http.MultipartRequest('POST', url);

      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['password_hash'] = password;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            filename: image.name,
          ),
        );
      }

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 201) {
        final user = jsonDecode(res.body);
        return {
          'success': true,
          'user': user,
        };
      } else {
        final decoded = jsonDecode(res.body);
        return {
          'success': false,
          'message': decoded['message'] ?? 'Erreur (${res.statusCode})',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message':
            "Impossible de contacter le serveur. Vérifie le Wi-Fi / IP du backend."
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': "Le serveur met trop de temps à répondre."
      };
    } catch (e) {
      return {'success': false, 'message': "Erreur inattendue : $e"};
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.authBase}/login_user'); 

    final body = {
      'username': username,
      'password_hash': password, 
    };

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {'success': true, 'user': data};
      } else {
        final decoded = jsonDecode(res.body);
        return {
          'success': false,
          'message': decoded['message'] ?? 'Erreur (${res.statusCode})',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message':
            "Impossible de contacter le serveur. Vérifie le Wi-Fi / IP du backend."
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': "Le serveur met trop de temps à répondre."
      };
    } catch (e) {
      return {'success': false, 'message': "Erreur inattendue : $e"};
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

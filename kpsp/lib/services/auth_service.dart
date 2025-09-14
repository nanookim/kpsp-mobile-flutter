// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class AuthService {
  /// 🔹 Register user baru
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/register'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  /// 🔹 Login user dan simpan token
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    // ❗ Cek status code dulu
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString(
            'userName',
            data['user']['username'] ?? data['user']['name'] ?? 'Pengguna',
          );
          await prefs.setString('userEmail', data['user']['email'] ?? '-');
        }

        return data;
      } catch (e) {
        // ❗ Jika bukan JSON (misal HTML)
        return {
          'success': false,
          'message': 'Server tidak merespons dengan JSON:\n${response.body}',
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Terjadi kesalahan server (${response.statusCode})',
      };
    }
  }

  /// 🔹 Logout user dan hapus token
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
  }

  /// 🔹 Ambil token tersimpan
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// 🔹 Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class AuthService {
  /// 🔹 Register user baru
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/register'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json", // penting biar Laravel selalu JSON
      },
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // ✅ sukses register
      return {
        "success": true,
        "message": data["message"],
        "user": data["user"],
      };
    } else if (response.statusCode == 422) {
      // ❌ validasi gagal
      return {
        "success": false,
        "message": data["message"],
        "errors": data["errors"], // bisa dipakai untuk detail error field
      };
    } else {
      // ❌ error lain
      return {
        "success": false,
        "message": "Terjadi kesalahan server (${response.statusCode})",
      };
    }
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

    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ Login sukses
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
      } else if (response.statusCode == 422) {
        // ✅ Error validasi dari Laravel (misal: email/password salah)
        return {
          'success': false,
          'message':
              data['errors']?['email']?.first ??
              data['message'] ??
              'Email atau password salah.',
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ??
              'Terjadi kesalahan server (${response.statusCode})',
        };
      }
    } catch (e) {
      // ❗ Jika respons bukan JSON (HTML error dsb.)
      return {
        'success': false,
        'message': 'Server tidak merespons dengan JSON:\n${response.body}',
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

  /// 🔹 Kirim link reset password
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/forgot-password'),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"email": email}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Request gagal [${response.statusCode}]: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak bisa terhubung ke server: $e',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reset-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "email": email,
          "password": password,
          "password_confirmation": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Request gagal [${response.statusCode}]: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak bisa terhubung ke server: $e',
      };
    }
  }
}

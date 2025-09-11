import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://kpsp.himogi.my.id/api";

  /// 🔹 Register
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username, // ✅ kirim "username" sesuai backend
        "email": email,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  /// 🔹 Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      // 🔹 Simpan token & user info ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setString(
        "userName",
        data["user"]["username"],
      ); // ✅ konsisten "username"
      await prefs.setString("userEmail", data["user"]["email"]);
    }

    return data;
  }
}

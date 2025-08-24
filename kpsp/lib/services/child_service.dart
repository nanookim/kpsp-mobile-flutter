import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../api_config.dart';

class ChildService {
  /// Ambil semua anak user
  Future<List<Map<String, dynamic>>> fetchChildren() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/children'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      List<Map<String, dynamic>> children = List<Map<String, dynamic>>.from(
        data['children'], // ✅ sesuaikan dengan API Laravel
      );
      return children;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch children');
    }
  }

  /// Tambah anak
  Future<Map<String, dynamic>> addChild(
    String name,
    String gender,
    String dob,
  ) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/children'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'gender': gender, 'date_of_birth': dob}),
    );

    return jsonDecode(response.body);
  }

  /// Update anak
  Future<Map<String, dynamic>> updateChild(
    int id,
    String name,
    String gender,
    String dob,
  ) async {
    final token = await AuthService().getToken();
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/children/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'gender': gender, 'date_of_birth': dob}),
    );

    return jsonDecode(response.body);
  }
}

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
      return List<Map<String, dynamic>>.from(data['children']);
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
    String birthHistory, {
    int? gestationalAge, // opsional
  }) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/children'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'gender': gender,
        'date_of_birth': dob,
        'birth_history': birthHistory,
        if (gestationalAge != null) 'gestational_age': gestationalAge,
      }),
    );

    return jsonDecode(response.body);
  }

  /// Update anak
  /// Update anak (pakai PATCH — lebih aman untuk partial update)
  Future<Map<String, dynamic>> updateChild(
    int id,
    String name,
    String gender,
    String dob,
    String birthHistory, {
    int? gestationalAge,
  }) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/children/$id');

    final body = {
      'name': name,
      'gender': gender,
      'date_of_birth': dob,
      'birth_history': birthHistory,
      if (gestationalAge != null) 'gestational_age': gestationalAge,
    };

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('PATCH $url');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to update child: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Request error: $e');
    }
  }
}

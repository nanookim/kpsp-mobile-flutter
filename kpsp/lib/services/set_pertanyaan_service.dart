import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class SetPertanyaanService {
  /// Ambil semua set pertanyaan
  Future<List<Map<String, dynamic>>> fetchSets(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/set-pertanyaan?id_anak=$childId'),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(
          data['message'] ?? 'Gagal mengambil data set pertanyaan',
        );
      }
    } catch (e) {
      throw Exception("fetchSets error: $e");
    }
  }

  /// Tambah set pertanyaan
  Future<Map<String, dynamic>> addSet({
    required int usiaDalamBulan,
    required int jumlahPertanyaan,
    String? deskripsi,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/set-pertanyaan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usia_dalam_bulan': usiaDalamBulan,
          'jumlah_pertanyaan': jumlahPertanyaan,
          'deskripsi': deskripsi,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("addSet error: $e");
    }
  }

  /// Detail set + pertanyaan
  Future<Map<String, dynamic>> getSetWithQuestions(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/set-pertanyaan/$id'),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Gagal ambil detail set');
      }
    } catch (e) {
      throw Exception("getSetWithQuestions error: $e");
    }
  }

  /// Update set
  Future<Map<String, dynamic>> updateSet({
    required int id,
    required int usiaDalamBulan,
    required int jumlahPertanyaan,
    String? deskripsi,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/set-pertanyaan/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usia_dalam_bulan': usiaDalamBulan,
          'jumlah_pertanyaan': jumlahPertanyaan,
          'deskripsi': deskripsi,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("updateSet error: $e");
    }
  }

  /// Hapus set
  Future<Map<String, dynamic>> deleteSet(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/set-pertanyaan/$id'),
        headers: {'Accept': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("deleteSet error: $e");
    }
  }

  /// Import file
  Future<Map<String, dynamic>> importFile(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/set-pertanyaan/import'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.headers['Accept'] = 'application/json';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("importFile error: $e");
    }
  }

  // ---------------------------SUBMIT JAWABAN---------------------------
  Future<Map<String, dynamic>> submitJawaban(
    int setId,
    int childId,
    Map<String, String> jawabanUser,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/set-pertanyaan/$setId/jawaban',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_anak': childId, // <--- kirim ke backend
          'jawaban': jawabanUser,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Status ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      throw Exception("submitJawaban error: $e");
    }
  }

  /// Ambil riwayat skrining anak
  Future<List<Map<String, dynamic>>> fetchRiwayat(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/set-pertanyaan/riwayat/$childId'),
        headers: {'Accept': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // backend return array skrining
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil riwayat skrining');
      }
    } catch (e) {
      throw Exception("fetchRiwayat error: $e");
    }
  }
}

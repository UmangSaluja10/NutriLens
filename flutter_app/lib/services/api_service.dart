import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Flutter Web on same PC as Flask → localhost:5000
  // Android emulator               → 10.0.2.2:5000
  // Real device (same WiFi)        → 192.168.x.x:5000
  static const String _baseUrl = 'http://localhost:5000';

  static Future<Map<String, dynamic>> predictFood(
      Uint8List imageBytes, String fileName) async {
    final uri = Uri.parse('$_baseUrl/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('image', imageBytes,
          filename: fileName));

    final streamed = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Timed out. Is Flask running?'),
    );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    final err = json.decode(response.body);
    throw Exception(err['error'] ?? 'Prediction failed (${response.statusCode})');
  }

  static Future<bool> isBackendAlive() async {
    try {
      final r = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
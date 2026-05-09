import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ── Replace with your Railway URL after deployment ────────────────────────
  // Railway URL format: 'https://nutrilens-backend-production.up.railway.app'
  // Local testing:      'http://localhost:5000'
  // Phone on WiFi:      'http://192.168.x.x:5000'
  static const String _baseUrl = 'https://nutrilens-production-db2e.up.railway.app';

  static Future<Map<String, dynamic>> predictFood(
      Uint8List imageBytes, String fileName) async {
    final uri = Uri.parse('$_baseUrl/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: fileName,
      ));

    // 60s timeout — Railway free tier may take 30s to wake from sleep
    final streamed = await request.send().timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw Exception(
          'Server is waking up. Please wait 30 seconds and try again.'),
    );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    final err = json.decode(response.body);
    throw Exception(
        err['error'] ?? 'Prediction failed (${response.statusCode})');
  }

  static Future<bool> isBackendAlive() async {
    try {
      final r = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 10));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
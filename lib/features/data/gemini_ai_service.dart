import 'dart:convert';

import 'package:flutter_application_1/features/domain/entities/message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiAIService {
  

  final String apiKey = dotenv.env['GEMINI_API_KEY']!; // .env dosyasına taşınabilir
  final String model = 'gemini-1.5-flash'; // veya gemini-pro vs

  Future<Message?> getGeminiResponse(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "Sen bir doktor asistanısın. Kullanıcının sorularına Türkçe ve sağlıklı açısından doğru, sade ve kibar cevaplar ver. Her cevabın sonuna 'mutlaka bir doktora danışmalısınız' ekle."},
            {"text": prompt}
          ]
        }
      ]
    });

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        Message responseMessage=Message(
        message: text,
        isUser: false,
      );
        return responseMessage;
      } else {
        print("Hata: ${response.statusCode} => ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}

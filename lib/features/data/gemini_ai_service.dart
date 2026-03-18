import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/features/domain/entities/message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiAIService {
  GeminiAIService();

  static const Duration _requestTimeout = Duration(seconds: 12);

  static const List<String> _candidateModels = [
    'gemini-2.0-flash',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  static const String _baseSystemPrompt =
      'Sen bir doktor asistanisin. Kullanicinin sorularina Turkce, sade ve kibar cevap ver. Her cevabin sonunda "mutlaka bir doktora danismalisiniz" ifadesi olsun.';

  String _getApiKey() {
    final raw = dotenv.env['GEMINI_API_KEY']?.trim();
    if (raw == null || raw.isEmpty) {
      throw Exception('GEMINI_API_KEY .env dosyasinda bulunamadi.');
    }

    final key = raw
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim();

    if (key.isEmpty) {
      throw Exception('GEMINI_API_KEY bos veya gecersiz.');
    }

    return key;
  }

  Uri _buildGenerateUri(String apiKey, String model) {
    return Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );
  }

  Message? _parseMessage(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return null;
    }

    final first = candidates.first as Map<String, dynamic>?;
    final content = first?['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return null;
    }

    final text = (parts.first as Map<String, dynamic>?)?['text']?.toString();
    if (text == null || text.trim().isEmpty) {
      return null;
    }

    return Message(
      message: text,
      isUser: false,
    );
  }

  Future<Message?> getGeminiResponse(String prompt, {String? profileContext}) async {
    final apiKey = _getApiKey();
    final systemPrompt =
        profileContext != null && profileContext.isNotEmpty
            ? '$_baseSystemPrompt\n$profileContext'
            : _baseSystemPrompt;

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": systemPrompt},
            {"text": prompt}
          ]
        }
      ]
    });

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      for (final model in _candidateModels) {
        final url = _buildGenerateUri(apiKey, model);

        http.Response? response;
        for (var attempt = 0; attempt < 2; attempt++) {
          try {
            response = await http
                .post(url, headers: headers, body: body)
                .timeout(_requestTimeout);
            break;
          } on TimeoutException {
            debugPrint('Gemini timeout [$model], deneme: ${attempt + 1}');
            if (attempt == 1) {
              response = null;
            }
          } catch (e) {
            debugPrint('Gemini istek hatasi [$model], deneme: ${attempt + 1} => $e');
            if (attempt == 1) {
              response = null;
            }
          }
        }

        if (response == null) {
          continue;
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return _parseMessage(data);
        }

        if (response.statusCode == 429 || response.statusCode == 503) {
          debugPrint('API rate limited veya unavailable. Sonraki model deneniyor: $model');
          continue;
        }

        if (response.statusCode == 404) {
          debugPrint('Model bulunamadi, sonraki model deneniyor: $model');
          continue;
        }

        debugPrint('Gemini API hatasi [$model]: ${response.statusCode} => ${response.body}');
        return null;
      }

      return null;
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }
}

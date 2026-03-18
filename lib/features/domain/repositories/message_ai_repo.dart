import 'package:flutter_application_1/features/data/gemini_ai_service.dart';
import 'package:flutter_application_1/features/data/health_profile_service.dart';
import 'package:flutter_application_1/features/domain/entities/message.dart';

class MessageAiRepo {
  final GeminiAIService aiService;
  final HealthProfileService profileService;
  final Map<String, String> _responseCache = {};
  static const int _maxContextMessages = 12;

  MessageAiRepo({
    required this.aiService,
    required this.profileService,
  });

  Future<Message?> sendToAI(
    String prompt, {
    String? userId,
    List<Message> conversationHistory = const [],
  }) async {
    final normalizedPrompt = prompt.toLowerCase().trim();
    final contextSignature = _buildContextSignature(conversationHistory);
    final cacheKey = '${userId ?? 'anon'}::$normalizedPrompt::$contextSignature';

    if (_responseCache.containsKey(cacheKey)) {
      return Message(
        message: _responseCache[cacheKey],
        isUser: false,
      );
    }

    String? profileContext;
    if (userId != null) {
      try {
        final profile = await profileService.getProfile(userId);
        if (profile != null) {
          profileContext = _buildProfileContext(profile);
        }
      } catch (_) {
        profileContext = null;
      }
    }

    final historyContext = _buildConversationContext(conversationHistory);
    final effectivePrompt = historyContext.isEmpty
        ? prompt
        : '$historyContext\n\nGuncel kullanici sorusu: $prompt';

    final response = await aiService.getGeminiResponse(
      effectivePrompt,
      profileContext: profileContext,
    );

    if (response != null) {
      _responseCache[cacheKey] = response.message ?? '';
    }

    return response;
  }

  String _buildProfileContext(dynamic profile) {
    try {
      final age = profile.age;
      final gender = profile.gender;
      final conditions = profile.chronicConditions;
      final allergies = profile.allergies;
      final medications = profile.medications;

      final parts = <String>[];
      if (age > 0) parts.add('yas: $age');
      if (gender.isNotEmpty) parts.add('cinsiyet: $gender');
      if (conditions.isNotEmpty) parts.add('kronik hastaliklar: $conditions');
      if (allergies.isNotEmpty) parts.add('alerjiler: $allergies');
      if (medications.isNotEmpty) parts.add('duzenli ilaclar: $medications');

      if (parts.isEmpty) return '';
      return 'Kullanicinin sag bilgileri: ${parts.join(", ")}';
    } catch (_) {
      return '';
    }
  }

  String _buildConversationContext(List<Message> history) {
    if (history.isEmpty) return '';

    final recent = history.length > _maxContextMessages
        ? history.sublist(history.length - _maxContextMessages)
        : history;

    final lines = <String>['Onceki konusma baglami:'];
    for (final item in recent) {
      final text = (item.message ?? '').trim();
      if (text.isEmpty) continue;
      final role = item.isUser ? 'Kullanici' : 'Asistan';
      lines.add('$role: $text');
    }

    if (lines.length == 1) return '';
    return lines.join('\n');
  }

  String _buildContextSignature(List<Message> history) {
    if (history.isEmpty) return 'noctx';

    final recent = history.length > 6
        ? history.sublist(history.length - 6)
        : history;

    return recent
        .map((m) => '${m.isUser ? 'u' : 'a'}:${(m.message ?? '').trim().toLowerCase()}')
        .join('|');
  }
}

      
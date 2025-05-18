import 'package:flutter_application_1/features/data/gemini_ai_service.dart';
import 'package:flutter_application_1/features/domain/entities/message.dart';

class MessageAiRepo {
  final GeminiAIService aiService;
  MessageAiRepo({required this.aiService});

  Future<Message?> sendToAI(String prompt) async {
    return await aiService.getGeminiResponse(prompt);
  }

}

      
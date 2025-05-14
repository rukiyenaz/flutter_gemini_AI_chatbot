import 'package:flutter_application_1/features/domain/entities/message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAIService {
  

  late final GenerativeModel model;

  GeminiAIService(){ 
          final apikey= dotenv.env['GEMINI_API_KEY']!,
          model = GenerativeModel(
          apiKey: apikey,
          model: 'gemini-1.5-flash',
          //promt girilecek
          systemInstruction: Content.system("sen bir doktorun, hastalarina çok nazik ve bilgilendirici şekilde yardimci oluyorsun, ve mesajlarinin sonunda her zaman 'mutlaka bir doktora görünmelisin' yazmalısın"),
        );
      }

  Future<Message?> getAiMessages(String message) async {
    try{
      final content=[Content.text(message)];
      final response=await model.generateContent(content);
      Message responseMessage=Message(
        message: response.text,
        isUser: false,
      );
      return responseMessage; 
    }catch(e){
      return Message(
        message: e.toString()+" ai den cevap yok",
        isUser: false,
      );  
    }
  }
  
}
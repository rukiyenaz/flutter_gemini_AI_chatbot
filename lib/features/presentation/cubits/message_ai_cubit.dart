import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/features/data/conversation_service.dart';
import 'package:flutter_application_1/features/domain/entities/conversation.dart';
import 'package:flutter_application_1/features/domain/entities/message.dart';
import 'package:flutter_application_1/features/domain/repositories/message_ai_repo.dart';
import 'package:flutter_application_1/features/presentation/cubits/message_ai_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageCubit extends Cubit<MessageState> {

  MessageCubit({
    required this.messageAiRepo,
    required this.conversationService,
  }) : super(MessageInitial(messages: []));

  final MessageAiRepo messageAiRepo;
  final ConversationService conversationService;
  String? currentConversationId;
  String? currentUserId;

  List<Message> _getCurrentMessages(MessageState state) {
  if (state is MessageSuccess) {
    return state.messages;
  } else if (state is MessageInitial) {
    return state.messages;
  } else if (state is MessageLoading) {
    return state.messages;
  } else if (state is MessageError) {
    return state.messages;
  } else {
    return []; // fallback olarak boş liste
  }
}
  void addMessage(Message message) {
    final stateMessages = _getCurrentMessages(state);
    emit(AddMessage(message: List.from(stateMessages)..add(message)));
  }
  

  void sendAiMessages(Message message, {String? userId}) async {
    final currentMessage = _getCurrentMessages(state);
    emit(MessageLoading(message: currentMessage));
    try {
      final response = await messageAiRepo.sendToAI(
        message.message ?? '',
        userId: userId,
        conversationHistory: currentMessage,
      );
      if (response != null) {
        final updatedMessage = List<Message>.from(currentMessage)
          ..add(Message(
            message: message.message,
            isUser: true,
          ))
          ..add(Message(
            message: response.message,
            isUser: false,
          ));
        emit(MessageSuccess(message: updatedMessage));
        await _saveConversation(userId, updatedMessage);
      } else {
        emit(MessageError(
          message: currentMessage,
          error: 'API limitine ulaş. (Quota Exceeded) Lütfen sonra tekrar deneyin.',
        ));
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('RESOURCE_EXHAUSTED') ||
          errorMsg.contains('429') ||
          errorMsg.contains('quota')) {
        errorMsg = 'API limitine ulaştı. Lütfen birkaç dakika sonra tekrar deneyin.';
      }
      emit(MessageError(message: currentMessage, error: errorMsg));
    }
  }

  Future<void> _saveConversation(String? userId, List<Message> messages) async {
    if (userId == null || messages.isEmpty) return;

    try {
      // İlk kez ise yeni konuşma oluştur
      if (currentConversationId == null) {
        currentConversationId = conversationService.generateNewConversationId();
        currentUserId = userId;
      }

      final title = conversationService.generateTitle(
        messages.firstWhere((m) => m.isUser, orElse: () => Message(message: 'Yeni Konusma')).message ?? 'Yeni Konusma'
      );

      final conversation = Conversation(
        conversationId: currentConversationId!,
        userId: userId,
        title: title,
        messages: messages,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await conversationService.saveConversation(conversation);
    } catch (e) {
      debugPrint('Konuşma kaydedilemedi: $e');
    }
  }

  void startNewConversation() {
    currentConversationId = null;
    currentUserId = null;
    emit(MessageInitial(messages: []));
  }

  Future<void> loadConversation(String userId, String conversationId) async {
    try {
      emit(MessageLoading(message: []));
      final conversation = await conversationService.getConversation(userId, conversationId);
      if (conversation != null) {
        currentConversationId = conversationId;
        currentUserId = userId;
        emit(MessageSuccess(message: conversation.messages));
      } else {
        emit(MessageError(message: [], error: 'Konuşma yüklenemedi'));
      }
    } catch (e) {
      emit(MessageError(message: [], error: 'Hata: $e'));
    }
  }

}
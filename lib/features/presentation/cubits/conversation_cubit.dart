import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/features/data/conversation_service.dart';
import 'package:flutter_application_1/features/domain/entities/conversation.dart';
import 'package:flutter_application_1/features/presentation/cubits/conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final ConversationService conversationService;

  ConversationCubit({required this.conversationService}) : super(ConversationInitial());

  Future<void> loadConversations(String userId, {int limit = 25}) async {
    try {
      emit(ConversationLoading());
      final conversations = await conversationService.getConversations(
        userId,
        limit: limit,
      );
      emit(ConversationListLoaded(conversations: conversations));
    } catch (e) {
      emit(ConversationError(message: 'Konuşmalar yüklenemedi: $e'));
    }
  }

  Future<void> loadConversation(String userId, String conversationId) async {
    try {
      emit(ConversationLoading());
      final conversation = await conversationService.getConversation(userId, conversationId);
      if (conversation != null) {
        emit(ConversationLoaded(conversation: conversation));
      } else {
        emit(ConversationError(message: 'Konuşma bulunamadı'));
      }
    } catch (e) {
      emit(ConversationError(message: 'Konuşma yüklenemedi: $e'));
    }
  }

  Future<void> saveConversation(Conversation conversation) async {
    try {
      emit(ConversationSaving());
      await conversationService.saveConversation(conversation);
      emit(ConversationSaved());
      // Konuşma listesini yenile
      await loadConversations(conversation.userId);
    } catch (e) {
      emit(ConversationError(message: 'Konuşma kaydedilemedi: $e'));
    }
  }

  Future<void> deleteConversation(String userId, String conversationId) async {
    try {
      emit(ConversationDeleting());
      await conversationService.deleteConversation(userId, conversationId);
      emit(ConversationDeleted());
      // Konuşma listesini yenile
      await loadConversations(userId);
    } catch (e) {
      emit(ConversationError(message: 'Konuşma silinemedi: $e'));
    }
  }
}

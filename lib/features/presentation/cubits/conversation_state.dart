import 'package:flutter_application_1/features/domain/entities/conversation.dart';

abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationListLoaded extends ConversationState {
  final List<Conversation> conversations;
  ConversationListLoaded({required this.conversations});
}

class ConversationLoaded extends ConversationState {
  final Conversation conversation;
  ConversationLoaded({required this.conversation});
}

class ConversationSaving extends ConversationState {}

class ConversationSaved extends ConversationState {}

class ConversationDeleting extends ConversationState {}

class ConversationDeleted extends ConversationState {}

class ConversationError extends ConversationState {
  final String message;
  ConversationError({required this.message});
}

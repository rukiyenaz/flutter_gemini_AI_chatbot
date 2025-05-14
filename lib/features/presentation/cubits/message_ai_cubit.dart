import 'package:flutter_application_1/features/domain/entities/message.dart';
import 'package:flutter_application_1/features/domain/repositories/message_ai_repo.dart';
import 'package:flutter_application_1/features/presentation/cubits/message_ai_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageCubit extends Cubit<MessageState> {

  MessageCubit({required this.messageAiRepo}) : super(MessageInitial(messages: []));

  final MessageAiRepo messageAiRepo;

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
  

  void sendAiMessages(Message message) async {
    final currentMessage =_getCurrentMessages(state);
    emit(MessageLoading(message: currentMessage));
    try {
      final response = await messageAiRepo.sendToAI(message.message ?? '');
      if (response != null) {
        final updatedMessage = List<Message>.from(currentMessage)..add(Message(
          message: message.message,
          isUser: true,
        ))..add(Message(
          message: response.message,
          isUser: false,
        ));
        emit(MessageSuccess(message: updatedMessage));
      } else {
        emit(MessageError(message: currentMessage, error: 'No response from AI'));
      }
    } catch (e) {
      emit(MessageError(message: currentMessage, error: e.toString()));
    }
  }

}
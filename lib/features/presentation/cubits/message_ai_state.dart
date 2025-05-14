
import 'package:flutter_application_1/features/domain/entities/message.dart';

abstract class MessageState {
  final List<Message> messages;
  MessageState({this.messages = const []});
  
}

//initial state
class MessageInitial extends MessageState {
  MessageInitial({required List<Message> messages}) : super(messages: messages);

}

//loading state
class MessageLoading extends MessageState {
  MessageLoading({required List<Message> message}) : super(messages: message);
}

//loaded state
class AddMessage extends MessageState {
  AddMessage({required List<Message> message}) : super(messages: message);

}

//succes state
class MessageSuccess extends MessageState {
  MessageSuccess({required List<Message> message}) : super(messages: message);
}

//error state
class MessageError extends MessageState {
  final String error;
  MessageError({required List<Message> message,required this.error}) : super(messages: message);
  
}
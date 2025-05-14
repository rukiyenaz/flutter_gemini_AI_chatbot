import 'package:flutter_application_1/features/domain/entities/message.dart';

abstract class MessageFirestoreRepo {
  Future<void> saveMessage(Message message);
}
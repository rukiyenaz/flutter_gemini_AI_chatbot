import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/domain/entities/message.dart';
import 'package:flutter_application_1/features/domain/repositories/message_firestore_repo.dart';

class FirebaseStoreMessage implements MessageFirestoreRepo {

  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _chatRef = FirebaseFirestore.instance.collection('messages');

  @override
  Future<void> saveMessage(Message message) async {
    try {
      await _chatRef.add({
        'message': message.message,
        'isUser': message.isUser,
      });
    } catch (e) {
      throw Exception('Error saving message: $e');
    }
  } 
}
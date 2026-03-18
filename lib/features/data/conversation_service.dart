import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/features/domain/entities/conversation.dart';
import 'package:uuid/uuid.dart';

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateConversationId() {
    return const Uuid().v4();
  }

  Future<void> saveConversation(Conversation conversation) async {
    try {
      await _firestore
          .collection('users')
          .doc(conversation.userId)
          .collection('conversations')
          .doc(conversation.conversationId)
          .set(conversation.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Konuşma kaydedilirken hata: $e');
    }
  }

  Future<List<Conversation>> getConversations(
    String userId, {
    int limit = 25,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Conversation.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Konuşmalar getirilirken hata: $e');
      return [];
    }
  }

  Future<Conversation?> getConversation(String userId, String conversationId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) return null;
      return Conversation.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('Konuşma getirilirken hata: $e');
      return null;
    }
  }

  Future<void> deleteConversation(String userId, String conversationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .delete();
    } catch (e) {
      debugPrint('Konuşma silinirken hata: $e');
    }
  }

  String generateNewConversationId() => _generateConversationId();

  String generateTitle(String firstMessage) {
    if (firstMessage.length > 30) {
      return '${firstMessage.substring(0, 30)}...';
    }
    return firstMessage;
  }
}

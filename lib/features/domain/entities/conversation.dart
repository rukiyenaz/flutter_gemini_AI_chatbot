import 'package:flutter_application_1/features/domain/entities/message.dart';

class Conversation {
  final String conversationId;
  final String userId;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.conversationId,
    required this.userId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'userId': userId,
      'title': title,
      'messages': messages.map((m) => {
        'message': m.message,
        'isUser': m.isUser,
      }).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return DateTime.now();

    final typeName = value.runtimeType.toString();
    if (typeName == 'Timestamp') {
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    final messagesList = (map['messages'] as List<dynamic>? ?? [])
        .map((m) => Message(
          message: m['message'] as String? ?? '',
          isUser: m['isUser'] as bool? ?? false,
        ))
        .toList();

    return Conversation(
      conversationId: map['conversationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      messages: messagesList,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Conversation copyWith({
    String? conversationId,
    String? userId,
    String? title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

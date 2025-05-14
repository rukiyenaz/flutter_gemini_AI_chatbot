class Message {
  String? message;
  bool isUser;

  Message({
    this.message,
    this.isUser = false,
  });

  factory Message.fromJson(Map<String, dynamic> json){
      return Message(
        message: json['message'],
        isUser: json['isUser'] ?? false,
      );
      }

  Map<String, dynamic> toJson() {
    return {
      'promt': message,
      'isUser': isUser,
    };
  }
}
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId, {required String currentUserId}) {
    final sender = map['senderId'] ?? '';
    return ChatMessage(
      id: docId,
      senderId: sender,
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isFromMe: sender == currentUserId,
    );
  }
}

class ChatThread {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserCollege;
  final String relatedItemTitle;
  final String relatedItemId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<ChatMessage> messages;

  const ChatThread({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserCollege,
    required this.relatedItemTitle,
    required this.relatedItemId,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.messages,
  });

  ChatThread copyWith({
    String? id,
    String? otherUserId,
    String? otherUserName,
    String? otherUserCollege,
    String? relatedItemTitle,
    String? relatedItemId,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    List<ChatMessage>? messages,
  }) {
    return ChatThread(
      id: id ?? this.id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserCollege: otherUserCollege ?? this.otherUserCollege,
      relatedItemTitle: relatedItemTitle ?? this.relatedItemTitle,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': [otherUserId],
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserCollege': otherUserCollege,
      'relatedItemTitle': relatedItemTitle,
      'relatedItemId': relatedItemId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  factory ChatThread.fromMap(Map<String, dynamic> map, String docId, {List<ChatMessage> messages = const []}) {
    return ChatThread(
      id: docId,
      otherUserId: map['otherUserId'] ?? '',
      otherUserName: map['otherUserName'] ?? '',
      otherUserCollege: map['otherUserCollege'] ?? '',
      relatedItemTitle: map['relatedItemTitle'] ?? '',
      relatedItemId: map['relatedItemId'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.tryParse(map['lastMessageTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
      messages: messages,
    );
  }
}

import '../models/chat_model.dart';

abstract class ChatRepository {
  Stream<List<ChatThread>> streamUserChats(String userId);
  Stream<List<ChatMessage>> streamMessages(String chatId, String currentUserId);
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  });
  Future<String> startOrGetChatThread({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
    required String otherUserCollege,
    required String relatedItemId,
    required String relatedItemTitle,
  });
}


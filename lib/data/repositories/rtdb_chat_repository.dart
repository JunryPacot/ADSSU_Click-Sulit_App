import 'package:firebase_database/firebase_database.dart';
import '../models/chat_model.dart';
import '../services/firebase_service.dart';
import 'chat_repository.dart';

class RtdbChatRepository implements ChatRepository {
  DatabaseReference get _ref => FirebaseService().database.ref('chats');

  @override
  Stream<List<ChatThread>> streamUserChats(String userId) {
    if (!FirebaseService().isInitialized) return Stream.value([]);
    return _ref.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return <ChatThread>[];
      final chats = <ChatThread>[];
      if (val is Map) {
        val.forEach((key, map) {
          if (map is Map) {
            try {
              final m = Map<String, dynamic>.from(map);
              final participants = List<String>.from(m['participantIds'] ?? []);
              if (participants.contains(userId)) {
                // Parse messages
                final msgsList = <ChatMessage>[];
                if (m['messages'] is Map) {
                  final msgsMap = Map<String, dynamic>.from(m['messages'] as Map);
                  msgsMap.forEach((msgKey, msgVal) {
                    if (msgVal is Map) {
                      try {
                        msgsList.add(ChatMessage.fromMap(
                          Map<String, dynamic>.from(msgVal),
                          msgKey.toString(),
                          currentUserId: userId,
                        ));
                      } catch (_) {}
                    }
                  });
                }
                msgsList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                final otherId = participants.firstWhere((p) => p != userId, orElse: () => 'user_unknown');
                final otherName = m['otherUserName'] ?? 'Adssunian';
                final otherCollege = m['otherUserCollege'] ?? '';
                final relItemTitle = m['relatedItemTitle'] ?? 'Listing';
                final relItemId = m['relatedItemId'] ?? 'item_general';
                final lastMsg = m['lastMessage'] ?? '';
                final lastTime = m['lastMessageTime'] != null
                    ? DateTime.tryParse(m['lastMessageTime'].toString()) ?? DateTime.now()
                    : DateTime.now();

                chats.add(ChatThread(
                  id: key.toString(),
                  otherUserId: otherId,
                  otherUserName: otherName,
                  otherUserCollege: otherCollege,
                  relatedItemTitle: relItemTitle,
                  relatedItemId: relItemId,
                  lastMessage: lastMsg,
                  lastMessageTime: lastTime,
                  messages: msgsList,
                ));
              }
            } catch (_) {}
          }
        });
      }
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return chats;
    });
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String chatId, String currentUserId) {
    if (!FirebaseService().isInitialized) return Stream.value([]);
    return _ref.child(chatId).child('messages').onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return <ChatMessage>[];
      final msgs = <ChatMessage>[];
      if (val is Map) {
        val.forEach((key, map) {
          if (map is Map) {
            try {
              msgs.add(ChatMessage.fromMap(
                Map<String, dynamic>.from(map),
                key.toString(),
                currentUserId: currentUserId,
              ));
            } catch (_) {}
          }
        });
      }
      msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return msgs;
    });
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (!FirebaseService().isInitialized) return;
    final now = DateTime.now();
    final msgRef = _ref.child(chatId).child('messages').push();
    await msgRef.set({
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': now.toIso8601String(),
    });
    await _ref.child(chatId).update({
      'lastMessage': text,
      'lastMessageTime': now.toIso8601String(),
    });
  }

  @override
  Future<String> startOrGetChatThread({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
    required String otherUserCollege,
    required String relatedItemId,
    required String relatedItemTitle,
  }) async {
    if (!FirebaseService().isInitialized) return 'chat_local';
    final snapshot = await _ref.get();
    final val = snapshot.value;
    if (val is Map) {
      for (final entry in val.entries) {
        if (entry.value is Map) {
          final m = Map<String, dynamic>.from(entry.value as Map);
          final participants = List<String>.from(m['participantIds'] ?? []);
          if (participants.contains(currentUserId) &&
              participants.contains(otherUserId) &&
              m['relatedItemId'] == relatedItemId) {
            return entry.key.toString();
          }
        }
      }
    }

    // Create new thread
    final newRef = _ref.push();
    final chatId = newRef.key ?? 'chat_${DateTime.now().millisecondsSinceEpoch}';
    await newRef.set({
      'participantIds': [currentUserId, otherUserId],
      'otherUserName': otherUserName,
      'otherUserCollege': otherUserCollege,
      'relatedItemId': relatedItemId,
      'relatedItemTitle': relatedItemTitle,
      'lastMessage': '',
      'lastMessageTime': DateTime.now().toIso8601String(),
    });
    return chatId;
  }
}
